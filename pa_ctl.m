function pa_ctl(cb_entries, gain, pa_idx, istx, gap_cyc, uart_fh)

% pa_idx needs to be in the range [1,8]
assert(pa_idx >= 1 && pa_idx <= 8 && round(pa_idx)==pa_idx);

% Write codebook entries
% Note that the BRAMs are zero-indexed internally (pa_idx)
fwrite(uart_fh, pa_ctl_seqbytes(uint16(cb_entries), uint16(gain), uint16(pa_idx), istx));

% Set end address
end_addr = length(cb_entries)-1;
assert(end_addr < 4095);
fwrite(uart_fh, pa_ctl_write_bytes(0, uint16(end_addr)));

% Set clock cycles per gap
assert(gap_cyc > 8); % Should be much larger, but smaller values cause problems
assert(gap_cyc < (2^16-1));
% The time_gap registerrs are indexed from 1 (0 is end_seq_addr)
fwrite(uart_fh, pa_ctl_write_bytes(uint16(pa_idx), uint16(gap_cyc)));

end

function send_bytes = pa_ctl_seqbytes(cb_entry, gain, pa_idx, istx)
if pa_idx > 8 || pa_idx < 0
    error("Invalid phased array index")
end
if istx > 1 || istx < 0
    error("Invalid istx value (choose 1 or 0)");
end
if any(cb_entry > 127 | cb_entry < 0)
    error("Invalid codebook selection");
end
if any(gain > 15 | gain < 0)
    error("Invalid gain value");
end

bram_sel = uint16(pa_idx-1);

addr=uint8(1:length(cb_entry))-1;

inner_data = bitshift(uint16(istx==1), 11) + bitshift(bitand(cb_entry, 127), 4) + bitand(gain, 15);

send_bytes = pa_ctl_write_bytes(addr, inner_data, bram_sel);

end

function send_bytes = pa_ctl_write_bytes(addr, data, bram_sel)
% Use 2 args for writing registers, 3 args for writing RAMs
if nargin==2
    bram_sel = 8; % 1<<3 selects a register, rather than a RAM
elseif bram_sel > 7 % b111
    error('Invalid bram index');
end

% Normalize inputs
addr = uint16(addr);
data = uint16(data);
bram_sel = uint16(bram_sel);

if bram_sel ~= 8
    if bitand(addr, 127) ~= addr
        error('BRAM address out of range');
    elseif bitand(data, 2^12-1) ~= data
        error('BRAM data out of range');
    end
    bytes = uint8([ ...
        % |   0   |    1    |    2   |   3   |   4   |   5   |   6   |   7   |
        % BRAM/reg|         BRAM select      |         BRAM addr MSB         |
        % Note: BRAM=0, reg = 1
        % BRAM select = XXX for register writes
        bitor(bitshift(bram_sel, 4), bitand(bitshift(addr, -3), 15)); ...
        % |   0   |    1    |    2   |   3   |   4   |   5   |   6   |   7   |
        % |      BRAM addr LSB       |         BRAM data MSB (5)             |
        bitor(bitshift(bitand(addr, 7), 5), bitand(bitshift(data, -7), 31)); ...
        % |   0   |    1    |    2   |   3   |   4   |   5   |   6   |   7   |
        % |                  BRAM data LSB (7 bits)                  |   X   |
        bitshift(bitand(data, 127), 1)]);
else
    if bitand(addr, 15) ~= addr
        error('register address out of range');
    elseif bitand(data, 2^16-1) ~= data
        error('register data out of range');
    end
    bytes = uint8([ ...
        % |   0   |    1    |    2   |   3   |   4   |   5   |   6   |   7   |
        % BRAM/reg|         BRAM select      |         register addr         |
        % Note: BRAM=0, reg = 1
        % BRAM select = XXX for register writes
        bitor(bitshift(bram_sel, 4), bitand(addr, 15)); ...
        % |   0   |    1    |    2   |   3   |   4   |   5   |   6   |   7   |
        % |                            Data                                  |
        bitand(bitshift(data, -8), 255); ...
        % |   0   |    1    |    2   |   3   |   4   |   5   |   6   |   7   |
        % |                            Data                                  |
        bitand(data, 255)]);
end

send_bytes = reshape(bytes, 1, numel(bytes));
end

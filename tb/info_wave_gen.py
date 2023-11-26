'''
    Author: Jiajun Wu, CASR, HKU
    Generate multipule sine waves (txt) including a sentence for a VHDL test bench.
    Default spec:
	    - sample rate 96kHz
'''

import math
import argparse
import random


def cal_sample_num(adc_rate, symbol_rate, head_tail=False):
    if head_tail == True:
        # need to keep for the head 4 symbols and tail 4 symbols
        samples_num = int(adc_rate*5/symbol_rate)
    else:
        samples_num = int(adc_rate/symbol_rate)
    return samples_num


# args = docopt(__doc__)
parser = argparse.ArgumentParser(description='testbench_config')
parser.add_argument(
    '--adc_bw', '-b', help='ADC bit width (default 12-bit)', default=12)
parser.add_argument(
    '--adc_freq', '-f', help='ADC sampling frequency (rate), default 96000', default=96000)
parser.add_argument(
    '--sym_rate', '-r', help='Symbol rate of decoder (default 16)', default=16)
parser.add_argument(
    '--info_str', '-s', help='Information which needs to be decoded (default FLATWHITE!)', default="FLATWHITE!")
args = parser.parse_args()

dic_table = {'A': ['2', '1'], 'B': ['1', '2'], 'C': ['3', '1'], 'D': ['1', '3'], 'E': ['4', '1'],
             'F': ['3', '2'], 'G': ['2', '3'], 'H': ['1', '4'], 'I': ['5', '1'], 'J': ['4', '2'],
             'K': ['2', '4'], 'L': ['1', '5'], 'M': ['6', '1'], 'N': ['5', '2'], 'O': ['4', '3'],
             'P': ['3', '4'], 'Q': ['2', '5'], 'R': ['1', '6'], 'S': ['6', '2'], 'T': ['5', '3'],
             'U': ['3', '5'], 'V': ['2', '6'], 'W': ['6', '3'], 'X': ['5', '4'], 'Y': ['4', '5'],
             'Z': ['3', '6'], '!': ['6', '4'], '.': ['4', '6'], ' ': ['6', '5'], '?': ['5', '6'],}

# frequency (Hz)
freq_table = {'0': 2093.00, '1': 1760.00, '2': 1396.91, '3': 1174.66,
                '4': 987.77, '5': 783.99, '6': 659.25, '7': 523.25}

symbol_rate = args.sym_rate
adc_samp_rate = int(args.adc_freq)
print(adc_samp_rate)
wave_bits = args.adc_bw
code_str = args.info_str
wave_amp = 2 ** (wave_bits - 1)

# noise_amp = int(wave_amp/20)
# noise_freq = 36000
# noise2_amp = int(wave_amp/20)
# noise2_freq = 45000
# noise3_amp = int(wave_amp/30)
# noise3_freq = 24000

print('-- Coding infomation into a symbol sequence')
print(code_str)
symbol_seq = ['0', '7', '0', '7']
for i in range(len(code_str)):
    symbol_seq = symbol_seq + dic_table.get(code_str[i])
symbol_seq = symbol_seq + ['7', '0', '7', '0']
print(symbol_seq)

print('-- Sine wave table generating')
sine_wave_list = []
total_samp_num = 0
for index in range(len(symbol_seq)):
    # head_tail = (index == 0) or (index == len(symbol_seq) - 1)
    wave_freq = freq_table.get(symbol_seq[index])
    samples_num = cal_sample_num(adc_samp_rate, symbol_rate, False)
    for samp in range(samples_num):
        new_sample = int(wave_amp * math.sin(2 * math.pi *
                                             wave_freq * samp / adc_samp_rate) + wave_amp)
        if new_sample > 4095:
            new_sample = 4095
        elif new_sample < 0:
            new_sample = 0
        bin_sample = (bin(((1 << 12) - 1) & new_sample)[2:]).zfill(12)
        sine_wave_list.append(bin_sample)
    total_samp_num += samples_num
print(total_samp_num)

print('-- Writing file')
with open("info_wave.txt", "w") as f:
    amp_index = 0
    for samp_amp in sine_wave_list:
        if amp_index < (total_samp_num - 1):
            f.write(samp_amp + '\n')
        else:
            f.write(samp_amp)
        amp_index += 1

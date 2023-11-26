import math
import wave
import struct
import argparse

# Audio will contain a long list of samples (i.e. floating point numbers describing the
# waveform).  If you were working with a very long sound you'd want to stream this to
# disk instead of buffering it all in memory list this.  But most sounds will fit in
# memory.


def append_silence(audio, sample_rate=96000, duration_milliseconds=500):
    """
    Adding silence is easy - we add zeros to the end of our array
    """
    num_samples = duration_milliseconds * (sample_rate / 1000.0)

    for x in range(int(num_samples)):
        audio.append(0.0)

    return


def append_sinewave(
    audio, freq=440.0, duration_milliseconds=62.5, sample_rate=96000, volume=1.0
):
    """
    The sine wave generated here is the standard beep.  If you want something
    more aggresive you could try a square or saw tooth waveform.   Though there
    are some rather complicated issues with making high quality square and
    sawtooth waves... which we won't address here :)
    """

    num_samples = duration_milliseconds * (sample_rate / 1000.0)

    for x in range(int(num_samples)):
        audio.append(volume * math.sin(2 * math.pi * freq * (x / sample_rate)))

    return


def save_wav(audio, sample_rate, file_name):
    # Open up a wav file
    wav_file = wave.open(file_name, "w")

    # wav params
    nchannels = 1

    sampwidth = 2

    # 44100 is the industry standard sample rate - CD quality.  If you need to
    # save on file size you can adjust it downwards. The stanard for low quality
    # is 8000 or 8kHz.
    nframes = len(audio)
    comptype = "NONE"
    compname = "not compressed"
    wav_file.setparams((nchannels, sampwidth, sample_rate, nframes, comptype, compname))

    # WAV files here are using short, 16 bit, signed integers for the
    # sample size.  So we multiply the floating point data we have by 32767, the
    # maximum value for a short integer.  NOTE: It is theortically possible to
    # use the floating point -1.0 to 1.0 data directly in a WAV file but not
    # obvious how to do that using the wave module in python.
    for sample in audio:
        wav_file.writeframes(struct.pack("h", int(sample * 32767.0)))

    wav_file.close()

    return


parser = argparse.ArgumentParser(description="testbench_config")
parser.add_argument(
    "--adc_freq",
    "-f",
    help="ADC sampling frequency (rate), default 96000",
    default=96000,
)
parser.add_argument(
    "--sym_rate", "-r", help="Symbol rate of decoder (default 16)", default=16
)
parser.add_argument(
    "--info_str",
    "-s",
    help="Information which needs to be decoded (default ENJOY FLATWHITE!)",
    default="ENJOY FLATWHITE!",
)
args = parser.parse_args()

dic_table = {
    "A": ["2", "1"],
    "B": ["1", "2"],
    "C": ["3", "1"],
    "D": ["1", "3"],
    "E": ["4", "1"],
    "F": ["3", "2"],
    "G": ["2", "3"],
    "H": ["1", "4"],
    "I": ["5", "1"],
    "J": ["4", "2"],
    "K": ["2", "4"],
    "L": ["1", "5"],
    "M": ["6", "1"],
    "N": ["5", "2"],
    "O": ["4", "3"],
    "P": ["3", "4"],
    "Q": ["2", "5"],
    "R": ["1", "6"],
    "S": ["6", "2"],
    "T": ["5", "3"],
    "U": ["3", "5"],
    "V": ["2", "6"],
    "W": ["6", "3"],
    "X": ["5", "4"],
    "Y": ["4", "5"],
    "Z": ["3", "6"],
    "!": ["6", "4"],
    ".": ["4", "6"],
    " ": ["6", "5"],
    "?": ["5", "6"],
}

# frequency (Hz)
freq_table = {
    "0": 2093.00,
    "1": 1760.00,
    "2": 1396.91,
    "3": 1174.66,
    "4": 987.77,
    "5": 783.99,
    "6": 659.25,
    "7": 523.25,
}

symbol_rate = args.sym_rate
sample_rate = int(args.adc_freq)
code_str = args.info_str
duration_milliseconds = 1000 / symbol_rate

print("-- Coding infomation into a symbol sequence")
print(code_str)
symbol_seq = ["0", "7", "0", "7"]
for i in range(len(code_str)):
    symbol_seq = symbol_seq + dic_table.get(code_str[i])
symbol_seq = symbol_seq + ["7", "0", "7", "0"]
print(symbol_seq)

print("-- Generating audio")
audio = []
for repeat_index in range(3):
    for index in range(len(symbol_seq)):
        # head_tail = (index == 0) or (index == len(symbol_seq) - 1)
        wave_freq = freq_table.get(symbol_seq[index])
        append_sinewave(
            audio, wave_freq, duration_milliseconds, sample_rate, volume=1.0
        )

print("-- Writing files")
save_wav(audio, sample_rate, "audio_waves.wav")

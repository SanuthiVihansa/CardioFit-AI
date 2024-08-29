import serial
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter, savgol_filter, iirnotch, filtfilt

# MY FUNCTION
def apply_savitzky_golay_filter_x(data):
  window_length = 11
  polyorder = 3
  x = data
  x = x.squeeze()
  x = savgol_filter(x, window_length, polyorder)
  return x[:, np.newaxis]

# my functionf
def butter_highpass_filter(data, cutoff_frequency, fs, order=4):
    nyquist = 0.5 * fs
    normal_cutoff = cutoff_frequency / nyquist
    b, a = butter(order, normal_cutoff, btype='highpass', analog=False)
    filtered_data = lfilter(b, a, data)
    return filtered_data

# my function
def butter_lowpass_filter(data, cutoff_frequency, fs, order=4):
    nyquist = 0.5 * fs
    normal_cutoff = cutoff_frequency / nyquist
    b, a = butter(order, normal_cutoff, btype='lowpass', analog=False)
    filtered_data = lfilter(b, a, data)
    return filtered_data

def apply_butterworth_filters_x(data):
  x = data[np.newaxis, :, np.newaxis]
  x = butter_highpass_filter(x, cutoff_frequency_high, fs, 4)
  x = butter_lowpass_filter(x, cutoff_frequency_low, fs, 4)
  return x

def apply_notch_filter(data):
    sig = data.squeeze()
    b, a = iirnotch(f0, Q, fs)
    sig = filtfilt(b, a, sig)
    sig = sig[:, np.newaxis]
    return sig

fs = 500.0  # Sampling frequency

cutoff_frequency_low = 50.0
cutoff_frequency_high = 0.5

f0 = 50.0   # Frequency to be removed from signal (Hz)
Q = 30.0    # Quality factor

# Set up the serial connection (adjust the port name as needed)
ser = serial.Serial('COM5', 9600)
data = []

try:
    while True:
        line = ser.readline().decode('utf-8').strip()
        if line.isdigit():
            data.append(int(line))

        if len(data) >= 5100:  # Plot data every 5000 samples
            data = data[100:]
            data = np.array(data).reshape(5000)
            data = apply_butterworth_filters_x(data)
            data = apply_savitzky_golay_filter_x(data)
            # (5000, 1)
            data = apply_notch_filter(data)
            plt.plot(data)
            plt.title('ECG Signal')
            plt.xlabel('Sample')
            plt.ylabel('Amplitude')
            plt.show()

            data = []
except KeyboardInterrupt:
    ser.close()
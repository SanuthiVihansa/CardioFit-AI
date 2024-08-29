import serial
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter, savgol_filter, resample

# Version 1
def butter_lowpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    return b, a

# Version 1
def butter_lowpass_filter(data, cutoff, fs, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = lfilter(b, a, data)
    return y

# Version 2
def apply_savitzky_golay_filter_x(data):
  window_length = 31
  polyorder = 3
  x = data
  x = savgol_filter(x.squeeze(), window_length, polyorder)
  return x[:, np.newaxis]

# Version 2
def butter_highpass_filter(data, cutoff_frequency, fs, order=4):
    nyquist = 0.5 * fs
    normal_cutoff = cutoff_frequency / nyquist
    b, a = butter(order, normal_cutoff, btype='highpass', analog=False)
    filtered_data = lfilter(b, a, data)
    return filtered_data

# Version 2
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

fs = 500.0  # Sampling frequency
cutoff = 50.0  # Desired cutoff frequency of the filter, Hz

cutoff_frequency_low = 200.0
cutoff_frequency_high = 0.5

# Set up the serial connection (adjust the port name as needed)
ser = serial.Serial('COM5', 9600)
data = []

try:
    while True:
        line = ser.readline().decode('utf-8').strip()
        if line.isdigit():
            data.append(int(line))

        if len(data) >= 1100:  # Plot data every 5000 samples
            data = data[100:]
            data = np.array(data).reshape(1000)
            data = apply_butterworth_filters_x(data)
            data = apply_savitzky_golay_filter_x(data)
            # data = apply_savitzky_golay_filter_x(data[np.newaxis, :])
            # data = apply_savitzky_golay_filter_x(data[np.newaxis, :])
            # data = data[:, np.newaxis]
            data = resample(data, 5000, axis=0)
            print(data)
            plt.plot(data)
            plt.title('ECG Signal')
            plt.xlabel('Sample')
            plt.ylabel('Amplitude')
            plt.show()

            # plt.figure(figsize=(24, 2))  # (width, height) in inches
            # time_data = np.arange(5000) / 500
            # plt.plot(time_data, x_train[i, :], label='ECG Signal')
            # # plt.plot(lead_2, 'y', label='ECG Signal')
            # plt.title("Initial Lead II ECG Signal")
            # #     plt.xlabel('Time(seconds)')
            # plt.ylabel('mV')
            # plt.legend()
            plt.show()

            data = []
except KeyboardInterrupt:
    ser.close()
import threading

import serial
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter, savgol_filter, iirnotch, filtfilt, resample
import time

def apply_savitzky_golay_filter_x(data):
  window_length = 11
  polyorder = 3
  x = data
  x = x.squeeze()
  x = savgol_filter(x, window_length, polyorder)
  return x[:, np.newaxis]

def butter_highpass_filter(data, cutoff_frequency, fs, order=4):
    nyquist = 0.5 * fs
    normal_cutoff = cutoff_frequency / nyquist
    b, a = butter(order, normal_cutoff, btype='highpass', analog=False)
    filtered_data = lfilter(b, a, data)
    return filtered_data

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

def start_timer():
    print("Timer started!")
    time.sleep(10)
    print("10 seconds have passed!")
    stop_reading_event.set()

fs = 500.0  # Sampling frequency

cutoff_frequency_low = 50.0
cutoff_frequency_high = 0.5

f0 = 50.0   # Frequency to be removed from signal (Hz)
Q = 30.0    # Quality factor

# Set up the serial connection (adjust the port name as needed)
ser = serial.Serial('COM5', 9600)
data = []
stop_reading_event = threading.Event()

try:
    while True:
        if stop_reading_event.is_set():
            print('Stopping data reading')
            break

        line = ser.readline().decode('utf-8').strip()
        if line.isdigit():
            data.append(int(line))

        if len(data) == 1:
            threading.Thread(target=start_timer).start()


        # if len(data) >= 2000:  # Plot data every 2000 samples (Because of 200Hz)
        #     data = np.array(data)
        #     data = resample(data, 5000, axis=0)
        #     data = apply_butterworth_filters_x(data)
        #     data = apply_savitzky_golay_filter_x(data)
        #     data = apply_notch_filter(data)
        #     plt.plot(data)
        #     plt.title('ECG Signal')
        #     plt.xlabel('Sample')
        #     plt.ylabel('Amplitude')
        #     plt.show()
        #
        #     data = []
    print(data)
except KeyboardInterrupt:
    ser.close()


"""
import threading

import serial
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter, savgol_filter, iirnotch, filtfilt, resample
import time

def apply_savitzky_golay_filter_x(data):
  window_length = 11
  polyorder = 3
  x = data
  x = x.squeeze()
  x = savgol_filter(x, window_length, polyorder)
  return x[:, np.newaxis]

def butter_highpass_filter(data, cutoff_frequency, fs, order=4):
    nyquist = 0.5 * fs
    normal_cutoff = cutoff_frequency / nyquist
    b, a = butter(order, normal_cutoff, btype='highpass', analog=False)
    filtered_data = lfilter(b, a, data)
    return filtered_data

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

def start_timer():
    print("Timer started!")
    time.sleep(10)
    print("10 seconds have passed!")
    stop_reading_event.set()

fs = 500.0  # Sampling frequency

cutoff_frequency_low = 50.0
cutoff_frequency_high = 0.5

f0 = 50.0   # Frequency to be removed from signal (Hz)
Q = 30.0    # Quality factor

# Set up the serial connection (adjust the port name as needed)
ser = serial.Serial('COM5', 9600)
data = []
stop_reading_event = threading.Event()

try:
    while True:
        if stop_reading_event.is_set():
            print('Stopping data reading')
            break

        line = ser.readline().decode('utf-8').strip()
        if line.isdigit():
            data.append(int(line))

        if len(data) == 1:
            threading.Thread(target=start_timer).start()


        # if len(data) >= 2000:  # Plot data every 2000 samples (Because of 200Hz)
        #     data = np.array(data)
        #     data = resample(data, 5000, axis=0)
        #     data = apply_butterworth_filters_x(data)
        #     data = apply_savitzky_golay_filter_x(data)
        #     data = apply_notch_filter(data)
        #     plt.plot(data)
        #     plt.title('ECG Signal')
        #     plt.xlabel('Sample')
        #     plt.ylabel('Amplitude')
        #     plt.show()
        #
        #     data = []
    print(data)
except KeyboardInterrupt:
    ser.close()

"""

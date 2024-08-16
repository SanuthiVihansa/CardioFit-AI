
# A very simple Flask Hello World app for you to get started with...

from flask import Flask, request, current_app, jsonify
import requests
from tensorflow.keras.models import load_model
import os
import shutil
import numpy as np
from scipy.signal import resample, iirnotch, filtfilt
import scipy.signal
from scipy.signal import savgol_filter
# import sklearn.metrics as sm
# import scipy.stats as stat

app = Flask(__name__)

# ====================== VARIABLES ======================

U_NET_MODEL_URL = "https://firebasestorage.googleapis.com/v0/b/cardioresp-ai.appspot.com/o/models%2Fmodel_all_norm_vals_noBnOn1Dconv_noAxis_noSplits_addedLayersAtEnd_lead1input.h5?alt=media&token=e119006c-eaeb-4d7f-860f-f019038dc4e1"
# TEMP_U_NET_MODEL_URL = "https://firebasestorage.googleapis.com/v0/b/cardioresp-ai.appspot.com/o/models%2Fmodel_all_norm_vals_noBnOn1Dconv_lead1-lead-v1-v6.h5?alt=media&token=69744061-7162-4314-871c-745f26aa1338"
sampling_rate=500
cutoff_frequency_low = 200.0
cutoff_frequency_high = 0.5
f0 = 50.0   # Frequency to be removed from signal (Hz) - Notch
Q = 30.0    # Quality factor - Notch

# ====================== METHODS ======================

def butter_highpass_filter(data, cutoff_frequency, sampling_rate, order=4):
    nyquist = 0.5 * sampling_rate
    normal_cutoff = cutoff_frequency / nyquist
#     b, a = scipy.signal.butter(order, normal_cutoff, btype='highpass', analog=False)
#     filtered_data = scipy.signal.lfilter(b, a, data, axis=1)
    b, a = scipy.signal.butter(order, normal_cutoff, btype='highpass')
    filtered_data = scipy.signal.lfilter(b, a, data)
    return filtered_data

def butter_lowpass_filter(data, cutoff_frequency, sampling_rate, order=4):
    nyquist = 0.5 * sampling_rate
    normal_cutoff = cutoff_frequency / nyquist
#     b, a = scipy.signal.butter(order, normal_cutoff, btype='lowpass', analog=False)
#     filtered_data = scipy.signal.lfilter(b, a, data, axis=1)
    b, a = scipy.signal.butter(order, normal_cutoff, btype='lowpass')
    filtered_data = scipy.signal.lfilter(b, a, data)
    return filtered_data

def apply_butterworth_filters_x(data):
    result_array = np.empty_like(data)
    for i in range(data.shape[0]):
        x = data[i, :, :].reshape((1, data.shape[1], 1))
        x = butter_highpass_filter(x, cutoff_frequency_high, sampling_rate, 4)
        x = butter_lowpass_filter(x, cutoff_frequency_low, sampling_rate, 4)
        result_array[i, :, :] = x
    return result_array

def apply_butterworth_filters_y(data):
    result_array = np.empty_like(data)
    for i in range(data.shape[0]):
        for lead in range(data.shape[2]):
            x = data[i, :, lead].reshape((1, data.shape[1], 1)) #reshapes the 2D slice into a 3D array
            x = butter_highpass_filter(x, cutoff_frequency_high, sampling_rate, 4)
            x = butter_lowpass_filter(x, cutoff_frequency_low, sampling_rate, 4)
            result_array[i, :, lead] = x.flatten() #specifies the target location in the result_array where the x array will be stored.
    return result_array

def apply_savitzky_golay_filter_x(data):
    result_array = np.empty_like(data)
    window_length = 31
    polyorder = 3
    for i in range(data.shape[0]):
        x = data[i, :, :].reshape((1, data.shape[1], 1))
        x = savgol_filter(x.squeeze(), window_length, polyorder)
        result_array[i, :, :] = x[:, np.newaxis]
    return result_array

def apply_savitzky_golay_filter_y(data):
    result_array = np.empty_like(data)
    window_length = 31
    polyorder = 3
    for i in range(data.shape[0]):
        for lead in range(data.shape[2]):
            x = data[i, :, lead].reshape((1, data.shape[1], 1))
            x = savgol_filter(x.squeeze(), window_length, polyorder)
            result_array[i, :, lead] = x
    return result_array

def min_max_normalize(signal):
    min_val = np.min(signal)
    max_val = np.max(signal)
    normalized_signal = (signal - min_val) / (max_val - min_val)
    return normalized_signal

def apply_notch_filter(data):
    data = data[0, :, :]
    sig = data.squeeze()
    b, a = iirnotch(f0, Q, sampling_rate)
    sig = filtfilt(b, a, sig)
    sig = sig[np.newaxis, :, np.newaxis]
    return sig






# ====================== CURRENT ROUTES ======================

@app.route('/')
def hello_world():
    return 'Hello from Flask!'

@app.route('/filtering', methods=['POST'])
def filtering():
    l1data = request.json
    l1_values = l1data['l1']
    l1_values = np.array(l1_values)
    l1_values = l1_values[np.newaxis, :, np.newaxis]
    l1_values = resample(l1_values, 5000, axis=1)

    l1_values = apply_butterworth_filters_x(l1_values)
    l1_values = apply_savitzky_golay_filter_x(l1_values)
    l1_values = apply_notch_filter(l1_values)

    l1_values[0, :, :] = min_max_normalize(l1_values[0, :, :])

    print(np.min(l1_values))
    print(np.max(l1_values))

    l1_values = l1_values[0, :, 0].tolist()

    # Create JSON object with the list
    response_data = {
        'l1': l1_values
        }

    # Send the JSON object through the response
    return jsonify(response_data)

@app.route('/upforunet')
def upforunet():
    try:
        temp_dir = "/home/poornasenadheera100/"
        if os.path.exists(temp_dir + "tempmodel.h5"):
            os.remove(temp_dir + "tempmodel.h5")
        model_path = os.path.join(temp_dir, 'model.h5')
        if not os.path.exists(model_path):
            print("Downloading model...")
            response = requests.get(U_NET_MODEL_URL, stream=True)
            print("Model downloaded")
            with open(model_path, 'wb') as f:
                shutil.copyfileobj(response.raw, f)
            print("Model saved")
            print("Working directory:", os.getcwd())
        loaded_model = load_model(model_path, compile=False)
        print("Model loaded")
        current_app.loaded_model = loaded_model
        return 'Server is up for U-NET'
    except requests.exceptions.RequestException as e:
        return f'Error downloading model: {e}', 500
    except Exception as e:
        return f'Error: {e}', 500

@app.route('/predict', methods=['POST'])
def predict():
    l1data = request.json
    l1_values = l1data['l1']
    l1_values = np.array(l1_values)
    l1_values = l1_values[np.newaxis, :, np.newaxis]

    # l1_values = apply_butterworth_filters_x(l1_values)
    # l1_values = apply_savitzky_golay_filter_x(l1_values)

    # l1_values[0, :, :] = min_max_normalize(l1_values[0, :, :])

    print(np.min(l1_values))
    print(np.max(l1_values))

    pred = current_app.loaded_model.predict(l1_values)

    pred = apply_savitzky_golay_filter_y(pred)

    print(pred.shape)

    l1_values_cpy = l1_values
    l2_values_cpy = pred[0, :, 0]
    l2_values_cpy = l2_values_cpy[np.newaxis, :, np.newaxis]

    l1_values = l1_values[0, :, 0].tolist()
    l2_values = pred[0, :, 0].tolist()
    v1_values = pred[0, :, 1].tolist()
    v2_values = pred[0, :, 2].tolist()
    v3_values = pred[0, :, 3].tolist()
    v4_values = pred[0, :, 4].tolist()
    v5_values = pred[0, :, 5].tolist()
    v6_values = pred[0, :, 6].tolist()

    l3_values = l2_values_cpy - l1_values_cpy
    l3_values_cpy = l3_values
    l3_values[0, :, :] = min_max_normalize(l3_values[0, :, :])
    l3_values = l3_values[0, :, 0].tolist()

    avr_values = (l1_values_cpy + l2_values_cpy) / (-2)
    avr_values[0, :, :] = min_max_normalize(avr_values[0, :, :])
    avr_values = avr_values[0, :, 0].tolist()

    avl_values = (l1_values_cpy - l3_values_cpy) / 2
    avl_values[0, :, :] = min_max_normalize(avl_values[0, :, :])
    avl_values = avl_values[0, :, 0].tolist()

    avf_values = (l2_values_cpy + l3_values_cpy) / 2
    avf_values[0, :, :] = min_max_normalize(avf_values[0, :, :])
    avf_values = avf_values[0, :, 0].tolist()

    # Create JSON object with the list
    response_data = {
        'l1' : l1_values,
        'l2': l2_values,
        'l3' : l3_values,
        'avr' : avr_values,
        'avl' : avl_values,
        'avf' : avf_values,
        'v1' : v1_values,
        'v2' : v2_values,
        'v3' : v3_values,
        'v4' : v4_values,
        'v5' : v5_values,
        'v6' : v6_values
        }

    # Send the JSON object through the response
    return jsonify(response_data)

# ====================== PP1 ROUTES ======================

# @app.route('/tempupforunet')
# def tempupforunet():
#     try:
#         temp_dir = "/home/poornasenadheera100/"
#         if os.path.exists(temp_dir + "model.h5"):
#             os.remove(temp_dir + "model.h5")
#         model_path = os.path.join(temp_dir, 'tempmodel.h5')
#         if not os.path.exists(model_path):
#             print("Downloading model...")
#             response = requests.get(TEMP_U_NET_MODEL_URL, stream=True)
#             print("Model downloaded")
#             with open(model_path, 'wb') as f:
#                 shutil.copyfileobj(response.raw, f)
#             print("Model saved")
#             print("Working directory:", os.getcwd())
#         loaded_model = load_model(model_path, compile=False)
#         print("Model loaded")
#         current_app.loaded_model = loaded_model
#         return 'Server is up for U-NET'
#     except requests.exceptions.RequestException as e:
#         return f'Error downloading model: {e}', 500
#     except Exception as e:
#         return f'Error: {e}', 500

# @app.route('/temppredict', methods=['POST'])
# def temppredict():
#     ecgdata = request.json

#     actl1_values = ecgdata['l1']
#     actl2_values = ecgdata['l2']
#     actv1_values = ecgdata['v1']
#     actv2_values = ecgdata['v2']
#     actv3_values = ecgdata['v3']
#     actv4_values = ecgdata['v4']
#     actv5_values = ecgdata['v5']
#     actv6_values = ecgdata['v6']


#     # Process actual l1

#     actl1_values = np.array(actl1_values)
#     actl1_values = actl1_values[np.newaxis, :, np.newaxis]


#     # Process actual l2

#     actl2_values = np.array(actl2_values)
#     actl2_values = actl2_values[np.newaxis, :, np.newaxis]


#     # Process actual l3

#     actl3_values = actl2_values - actl1_values


#     # Process actual avr

#     actavr_values = ((actl1_values + actl2_values) / 2) * -1
#     actavr_values[0, :, :] = min_max_normalize(actavr_values[0, :, :])

#     # Process actual avl

#     actavl_values = (actl1_values - actl3_values) / 2
#     actavl_values[0, :, :] = min_max_normalize(actavl_values[0, :, :])

#     # Process actual avf

#     actavf_values = (actl2_values + actl3_values) / 2
#     actavf_values[0, :, :] = min_max_normalize(actavf_values[0, :, :])


#     # Normalizing L1, L2 and L3
#     actl1_values[0, :, :] = min_max_normalize(actl1_values[0, :, :])
#     actl2_values[0, :, :] = min_max_normalize(actl2_values[0, :, :])
#     actl3_values[0, :, :] = min_max_normalize(actl3_values[0, :, :])


#     # Process actual v1

#     actv1_values = np.array(actv1_values)
#     actv1_values = actv1_values[np.newaxis, :, np.newaxis]
#     actv1_values[0, :, :] = min_max_normalize(actv1_values[0, :, :])

#     # Process actual v2

#     actv2_values = np.array(actv2_values)
#     actv2_values = actv2_values[np.newaxis, :, np.newaxis]
#     actv2_values[0, :, :] = min_max_normalize(actv2_values[0, :, :])

#     # Process actual v3

#     actv3_values = np.array(actv3_values)
#     actv3_values = actv3_values[np.newaxis, :, np.newaxis]
#     actv3_values[0, :, :] = min_max_normalize(actv3_values[0, :, :])

#     # Process actual v4

#     actv4_values = np.array(actv4_values)
#     actv4_values = actv4_values[np.newaxis, :, np.newaxis]
#     actv4_values[0, :, :] = min_max_normalize(actv4_values[0, :, :])

#     # Process actual v5

#     actv5_values = np.array(actv5_values)
#     actv5_values = actv5_values[np.newaxis, :, np.newaxis]
#     actv5_values[0, :, :] = min_max_normalize(actv5_values[0, :, :])

#     # Process actual v6

#     actv6_values = np.array(actv6_values)
#     actv6_values = actv6_values[np.newaxis, :, np.newaxis]
#     actv6_values[0, :, :] = min_max_normalize(actv6_values[0, :, :])

#     # Prediction

#     pred = current_app.loaded_model.predict(actl2_values)
#     pred = apply_savitzky_golay_filter_y(pred)

#     # Getting predicted values
#     predl1_values = pred[:, :, 0]
#     predl1_values = predl1_values[:, :, np.newaxis]

#     predl3_values = actl2_values - predl1_values
#     predavr_values = ((predl1_values + actl2_values) / 2) * -1
#     predavl_values = (predl1_values - predl3_values) / 2
#     predavf_values = (actl2_values + predl3_values) / 2
#     predv1_values = pred[0, :, 1]
#     predv2_values = pred[0, :, 2]
#     predv3_values = pred[0, :, 3]
#     predv4_values = pred[0, :, 4]
#     predv5_values = pred[0, :, 5]
#     predv6_values = pred[0, :, 6]

#     # Calculating mse, P and R2
#     actl1_values_reshaped = actl1_values.reshape(-1)
#     predl1_values_reshaped = predl1_values.reshape(-1)
#     l1mse = sm.mean_squared_error(actl1_values_reshaped, predl1_values_reshaped)
#     l1p = stat.pearsonr(actl1_values_reshaped, predl1_values_reshaped)[0]
#     l1r2 = sm.r2_score(actl1_values_reshaped, predl1_values_reshaped)

#     actl3_values_reshaped = actl3_values.reshape(-1)
#     predl3_values_reshaped = predl3_values.reshape(-1)
#     l3mse = sm.mean_squared_error(actl3_values_reshaped, predl3_values_reshaped)
#     l3p = stat.pearsonr(actl3_values_reshaped, predl3_values_reshaped)[0]
#     l3r2 = sm.r2_score(actl3_values_reshaped, predl3_values_reshaped)

#     actavr_values_reshaped = actavr_values.reshape(-1)
#     predavr_values_reshaped = predavr_values.reshape(-1)
#     avrmse = sm.mean_squared_error(actavr_values_reshaped, predavr_values_reshaped)
#     avrp = stat.pearsonr(actavr_values_reshaped, predavr_values_reshaped)[0]
#     avrr2 = sm.r2_score(actavr_values_reshaped, predavr_values_reshaped)

#     actavl_values_reshaped = actavl_values.reshape(-1)
#     predavl_values_reshaped = predavl_values.reshape(-1)
#     avlmse = sm.mean_squared_error(actavl_values_reshaped, predavl_values_reshaped)
#     avlp = stat.pearsonr(actavl_values_reshaped, predavl_values_reshaped)[0]
#     avlr2 = sm.r2_score(actavl_values_reshaped, predavl_values_reshaped)

#     actavf_values_reshaped = actavf_values.reshape(-1)
#     predavf_values_reshaped = predavf_values.reshape(-1)
#     avfmse = sm.mean_squared_error(actavf_values_reshaped, predavf_values_reshaped)
#     avfp = stat.pearsonr(actavf_values_reshaped, predavf_values_reshaped)[0]
#     avfr2 = sm.r2_score(actavf_values_reshaped, predavf_values_reshaped)

#     actv1_values_reshaped = actv1_values.reshape(-1)
#     predv1_values_reshaped = predv1_values.reshape(-1)
#     v1mse = sm.mean_squared_error(actv1_values_reshaped, predv1_values_reshaped)
#     v1p = stat.pearsonr(actv1_values_reshaped, predv1_values_reshaped)[0]
#     v1r2 = sm.r2_score(actv1_values_reshaped, predv1_values_reshaped)

#     actv2_values_reshaped = actv2_values.reshape(-1)
#     predv2_values_reshaped = predv2_values.reshape(-1)
#     v2mse = sm.mean_squared_error(actv2_values_reshaped, predv2_values_reshaped)
#     v2p = stat.pearsonr(actv2_values_reshaped, predv2_values_reshaped)[0]
#     v2r2 = sm.r2_score(actv2_values_reshaped, predv2_values_reshaped)

#     actv3_values_reshaped = actv3_values.reshape(-1)
#     predv3_values_reshaped = predv3_values.reshape(-1)
#     v3mse = sm.mean_squared_error(actv3_values_reshaped, predv3_values_reshaped)
#     v3p = stat.pearsonr(actv3_values_reshaped, predv3_values_reshaped)[0]
#     v3r2 = sm.r2_score(actv3_values_reshaped, predv3_values_reshaped)

#     actv4_values_reshaped = actv4_values.reshape(-1)
#     predv4_values_reshaped = predv4_values.reshape(-1)
#     v4mse = sm.mean_squared_error(actv4_values_reshaped, predv4_values_reshaped)
#     v4p = stat.pearsonr(actv4_values_reshaped, predv4_values_reshaped)[0]
#     v4r2 = sm.r2_score(actv4_values_reshaped, predv4_values_reshaped)

#     actv5_values_reshaped = actv5_values.reshape(-1)
#     predv5_values_reshaped = predv5_values.reshape(-1)
#     v5mse = sm.mean_squared_error(actv5_values_reshaped, predv5_values_reshaped)
#     v5p = stat.pearsonr(actv5_values_reshaped, predv5_values_reshaped)[0]
#     v5r2 = sm.r2_score(actv5_values_reshaped, predv5_values_reshaped)

#     actv6_values_reshaped = actv6_values.reshape(-1)
#     predv6_values_reshaped = predv6_values.reshape(-1)
#     v6mse = sm.mean_squared_error(actv6_values_reshaped, predv6_values_reshaped)
#     v6p = stat.pearsonr(actv6_values_reshaped, predv6_values_reshaped)[0]
#     v6r2 = sm.r2_score(actv6_values_reshaped, predv6_values_reshaped)

#     # Preparing JSON

#     actl1_values = actl1_values[0, :, 0].tolist()
#     predl1_values = predl1_values[0, :, 0].tolist()

#     actl2_values = actl2_values[0, :, 0].tolist()

#     actl3_values = actl3_values[0, :, 0].tolist()
#     predl3_values = predl3_values[0, :, 0].tolist()

#     actavr_values = actavr_values[0, :, 0].tolist()
#     predavr_values = predavr_values[0, :, 0].tolist()

#     actavl_values = actavl_values[0, :, 0].tolist()
#     predavl_values = predavl_values[0, :, 0].tolist()

#     actavf_values = actavf_values[0, :, 0].tolist()
#     predavf_values = predavf_values[0, :, 0].tolist()

#     actv1_values = actv1_values[0, :, 0].tolist()
#     predv1_values = pred[0, :, 1].tolist()

#     actv2_values = actv2_values[0, :, 0].tolist()
#     predv2_values = pred[0, :, 2].tolist()

#     actv3_values = actv3_values[0, :, 0].tolist()
#     predv3_values = pred[0, :, 3].tolist()

#     actv4_values = actv4_values[0, :, 0].tolist()
#     predv4_values = pred[0, :, 4].tolist()

#     actv5_values = actv5_values[0, :, 0].tolist()
#     predv5_values = pred[0, :, 5].tolist()

#     actv6_values = actv6_values[0, :, 0].tolist()
#     predv6_values = pred[0, :, 6].tolist()

#     # Create JSON object with the list
#     response_data = {
#         'actl1' : actl1_values,
#         'predl1' : predl1_values,
#         'l1mse' : l1mse,
#         'l1p' : l1p,
#         'l1r2' : l1r2,

#         'actl2': actl2_values,

#         'actl3' : actl3_values,
#         'predl3': predl3_values,
#         'l3mse' : l3mse,
#         'l3p' : l3p,
#         'l3r2' : l3r2,

#         'actavr' : actavr_values,
#         'predavr' : predavr_values,
#         'avrmse' : avrmse,
#         'avrp' : avrp,
#         'avrr2' : avrr2,

#         'actavl' : actavl_values,
#         'predavl' : predavl_values,
#         'avlmse' : avlmse,
#         'avlp' : avlp,
#         'avlr2' : avlr2,

#         'actavf' : actavf_values,
#         'predavf' : predavf_values,
#         'avfmse' : avfmse,
#         'avfp' : avfp,
#         'avfr2' : avfr2,

#         'actv1' : actv1_values,
#         'predv1' : predv1_values,
#         'v1mse' : v1mse,
#         'v1p' : v1p,
#         'v1r2' : v1r2,

#         'actv2' : actv2_values,
#         'predv2' : predv2_values,
#         'v2mse' : v2mse,
#         'v2p' : v2p,
#         'v2r2' : v2r2,

#         'actv3' : actv3_values,
#         'predv3' : predv3_values,
#         'v3mse' : v3mse,
#         'v3p' : v3p,
#         'v3r2' : v3r2,

#         'actv4' : actv4_values,
#         'predv4' : predv4_values,
#         'v4mse' : v4mse,
#         'v4p' : v4p,
#         'v4r2' : v4r2,

#         'actv5' : actv5_values,
#         'predv5' : predv5_values,
#         'v5mse' : v5mse,
#         'v5p' : v5p,
#         'v5r2' : v5r2,

#         'actv6' : actv6_values,
#         'predv6' : predv6_values,
#         'v6mse' : v6mse,
#         'v6p' : v6p,
#         'v6r2' : v6r2
#         }

#     # Send the JSON object through the response
#     return jsonify(response_data)

# ====================== INITIAL ROUTES ======================

# @app.route('/upforunet')
# def upforunet():
#     try:
#         temp_dir = "/home/poornasenadheera100/"
#         if os.path.exists(temp_dir + "tempmodel.h5"):
#             os.remove(temp_dir + "tempmodel.h5")
#         model_path = os.path.join(temp_dir, 'model.h5')
#         if not os.path.exists(model_path):
#             print("Downloading model...")
#             response = requests.get(U_NET_MODEL_URL, stream=True)
#             print("Model downloaded")
#             with open(model_path, 'wb') as f:
#                 shutil.copyfileobj(response.raw, f)
#             print("Model saved")
#             print("Working directory:", os.getcwd())
#         loaded_model = load_model(model_path, compile=False)
#         print("Model loaded")
#         current_app.loaded_model = loaded_model
#         return 'Server is up for U-NET'
#     except requests.exceptions.RequestException as e:
#         return f'Error downloading model: {e}', 500
#     except Exception as e:
#         return f'Error: {e}', 500

# @app.route('/predict', methods=['POST'])
# def predict():
#     l2data = request.json
#     l2_values = l2data['l2']
#     l2_values = np.array(l2_values)
#     l2_values = l2_values[np.newaxis, :, np.newaxis]
#     l2_values = resample(l2_values, 5000, axis=1)
#     # print(l2_values.shape)

#     l2_values = apply_butterworth_filters_x(l2_values)
#     l2_values = apply_savitzky_golay_filter_x(l2_values)

#     l2_values[0, :, :] = min_max_normalize(l2_values[0, :, :])

#     print(np.min(l2_values))
#     print(np.max(l2_values))

#     pred = current_app.loaded_model.predict(l2_values)

#     pred = apply_savitzky_golay_filter_y(pred)

#     print(pred.shape)

#     l1_values = pred[0, :, 0].tolist()
#     l2_values = l2_values[0, :, 0].tolist()
#     l3_values = pred[0, :, 1].tolist()
#     avr_values = pred[0, :, 2].tolist()
#     avl_values = pred[0, :, 3].tolist()
#     avf_values = pred[0, :, 4].tolist()
#     v1_values = pred[0, :, 5].tolist()
#     v2_values = pred[0, :, 6].tolist()
#     v3_values = pred[0, :, 7].tolist()
#     v4_values = pred[0, :, 8].tolist()
#     v5_values = pred[0, :, 9].tolist()
#     v6_values = pred[0, :, 10].tolist()

#     # Create JSON object with the list
#     response_data = {
#         'l1' : l1_values,
#         'l2': l2_values,
#         'l3' : l3_values,
#         'avr' : avr_values,
#         'avl' : avl_values,
#         'avf' : avf_values,
#         'v1' : v1_values,
#         'v2' : v2_values,
#         'v3' : v3_values,
#         'v4' : v4_values,
#         'v5' : v5_values,
#         'v6' : v6_values
#         }

#     # Send the JSON object through the response
#     return jsonify(response_data)


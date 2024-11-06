# imports
import os
import shutil
import requests
import numpy as np
import pandas as pd
from shap import DeepExplainer
from scipy.ndimage import zoom
from tensorflow.keras.models import load_model
import tensorflow as tf
from flask import Flask, request, jsonify, current_app

app = Flask(__name__)

# Variables
baseline_model_url = "https://firebasestorage.googleapis.com/v0/b/cardioresp-ai.appspot.com/o/models%2Fbaseline_model.h5?alt=media&token=9cbea268-693c-4834-81a4-78ede6620474"

# Knowledge Base of Doctors' Features for Specific Diseases
knowledge_base = {
    'ISCAL': {
        'full_name': 'Ischemic in Anterolateral Leads',
        'leads': ['V3', 'V4', 'V5', 'V6', 'I', 'aVL'],
        'features': ['ST-segment depression']
    },
    'NST': {
        'full_name': 'Non-Specific ST Changes',
        'leads': 'all',
        'features': ['ST-segment depression or elevation without clear ischemic pattern']
    },
    'SARRH': {
        'full_name': 'Sinus Arrhythmia',
        'leads': 'all',
        'features': ['Irregular R-R intervals', 'Normal P waves']
    },
    'IVCD': {
        'full_name': 'Non-Specific Intraventricular Conduction Disturbances',
        'leads': 'all',
        'features': ['Prolongation of QRS complex (>0.12 seconds)', 'Abnormal QRS morphology']
    },
    '1AVB': {
        'full_name': 'First-Degree AV Block',
        'leads': 'all',
        'features': ['Prolongation of PR interval (>200 ms)', 'P waves followed by QRS complexes']
    },
    'STACH': {
        'full_name': 'Sinus Tachycardia',
        'leads': 'all',
        'features': ['Increased heart rate (>100 bpm)', 'Normal P wave morphology preceding each QRS']
    },
    'VCLVH': {
        'full_name': 'Voltage Criteria for Left Ventricular Hypertrophy',
        'leads': ['I', 'aVL', 'V1', 'V2', 'V3', 'V5', 'V6'],
        'features': ['ST elevation', 'T wave inversion']
    },
    'AFIB': {
        'full_name': 'Atrial Fibrillation',
        'leads': 'all',
        'features': ['Irregularly irregular rhythm', 'Absence of distinct P waves']
    },
    'IMI': {
        'full_name': 'Inferior Myocardial Infarction',
        'leads': ['I', 'II', 'III', 'aVL', 'aVF', 'V5', 'V6'],
        'features': ['ST-segment elevation in leads II, III, and aVF', 'Reciprocal changes in leads I, aVL, V5, and V6']
    },
    'STD_': {
        'full_name': 'Non-Specific ST Depression',
        'leads': ['V2', 'V3', 'V4', 'V5', 'V6'],
        'features': [
          'Mild, downward-sloping ST depression',
          'No clear ischemic pattern, may indicate subendocardial ischemia or other abnormalities']
    },
    'IRBBB': {
        'full_name': 'Incomplete Right Bundle Branch Block',
        'leads': ['V1', 'V2'],
        'features': [
          'Prolonged terminal R wave in V1 or V2',
          'QRS duration between 110–120 ms',
          'May indicate RVH or be benign']
    },
    'PVC': {
        'full_name': 'Ventricular Premature Complex',
        'leads': 'all',
        'features': [
          'Early, wide QRS complex that interrupts the normal rhythm',
          'Often without a preceding P wave, indicating ectopic ventricular beats']
    },
    'ISC_': {
        'full_name': 'Non-Specific Ischemic Changes',
        'leads': 'all',
        'features': ['Subtle or diffuse ST-segment changes', 'T-wave flattening or inversion']
    },
    'LAFB': {
        'full_name': 'Left Anterior Fascicular Block',
        'leads': ['I', 'aVL', 'II', 'III', 'aVF'],
        'features': [
          'Left axis deviation',
          'qR complexes in I and aVL',
          'Prolonged R wave peak time in aVL']
    },
    'NDT': {
        'full_name': 'Non-Diagnostic T Abnormalities',
        'leads': 'all',
        'features': [
          'T-wave changes without a clear diagnostic pattern',
          'May indicate electrolyte disturbances or subtle ischemic changes']
    },
    'LVH': {
        'full_name': 'Left Ventricular Hypertrophy',
        'leads': ['I', 'aVL', 'V1', 'V2', 'V3', 'V4', 'V5', 'V6'],
        'features': [
          'High voltage QRS complexes',
          'ST-segment depression and T-wave inversion indicating strain']
    },
    'ASMI': {
        'full_name': 'Anteroseptal Myocardial Infarction',
        'leads': ['V1', 'V2', 'V3', 'V4'],
        'features': [
          'ST-segment elevation in V1–V4',
          'Pathological Q waves indicating infarction in anterior and septal walls']
    },
    'ABQRS': {
        'full_name': 'Abnormal QRS Complex',
        'leads': 'all',
        'features': [
          'Variations in QRS duration, morphology, or axis',
          'May indicate conduction disturbances or ectopic rhythms']
    },
    'NORM': {
        'full_name': 'Normal ECG',
        'leads': 'all',
        'features': [
          'Consistent P wave before every QRS complex',
          'Normal PR interval (120-200 ms)',
          'Narrow QRS complex (<120 ms)',
          'Regular rhythm with standard heart rate (60-100 bpm)']
    },
    'SR': {
        'full_name': 'Sinus Rhythm',
        'leads': 'all',
        'features': [
          'Regular R-R intervals',
          'P wave before each QRS complex',
          'Standard heart rate (60-100 bpm)',
          'Normal axis and no abnormal findings in rhythm']
    }
}

lead_mapping = {
    'Lead 1': 'I',
    'Lead 2': 'II',
    'Lead 3': 'III',
    'Lead 4': 'aVR',
    'Lead 5': 'aVL',
    'Lead 6': 'aVF',
    'Lead 7': 'V1',
    'Lead 8': 'V2',
    'Lead 9': 'V3',
    'Lead 10': 'V4',
    'Lead 11': 'V5',
    'Lead 12': 'V6'
}

# Helper function to get GradCAM heatmap
def get_gradcam_heatmap(model, input_data, class_index):
    print("Input data shape:", input_data.shape)
    grad_model = tf.keras.models.Model([model.inputs], [model.get_layer('conv1d').output, model.output]) #?
    with tf.GradientTape() as tape:
        conv_outputs, predictions = grad_model(input_data)
        loss = predictions[:, class_index]
    grads = tape.gradient(loss, conv_outputs)
    print('Shape of grads: ', grads.shape)
    pooled_grads = tf.reduce_mean(grads, axis=(0, 1))
    conv_outputs = conv_outputs[0] #remove batch dimension
    heatmap = tf.reduce_mean(conv_outputs * pooled_grads, axis=-1).numpy()
    heatmap = np.maximum(heatmap, 0) / np.max(heatmap)
    return heatmap

# routes
@app.route('/')
def hello_world():
    return 'Hello from Flask!'

@app.route('/load/trainData')
def loadTrainData():
    print("loadTrainData endpoint was called")
    try:
        temp_dir = "/home/swije/mysite/"
        train_data_path = os.path.join(temp_dir, '10_train_ecg_data.npy')
        print("Loading train data...")
        # replace with actual training data if needed
        # train_ecg = np.random.rand(10, 5000, 12)
        if not hasattr(current_app, 'train_ecg'):
            print('Current app does not have train_ecg')
            train_ecg = np.load(train_data_path)
            current_app.train_ecg = train_ecg
        print("Data loaded successfully")
        return 'Train data successfully loaded'
    except requests.exceptions.RequestException as e:
        print(f"Error loading data: {e}")
        return f'Error loading data: {e}', 500
    except Exception as e:
        print(f"Error: {e}")
        return f'Error: {e}', 500

@app.route('/load/model')
def loadBaseLineModel():
    try:
        # Load training data immediately after loading the model
        loadTrainData()

        temp_dir = "/home/swije/"
        model_path = os.path.join(temp_dir, 'baseline_model.h5')

        if not os.path.exists(model_path):
            print("Downloading model...")
            response = requests.get(baseline_model_url, stream=True)
            print("Model downloaded")
            with open(model_path, 'wb') as f:
                shutil.copyfileobj(response.raw, f)
            print("Model saved")
            print("Working directory:", os.getcwd())

        print("Loading model...")
        if not hasattr(current_app, 'loaded_model'):
            print('Current app does not have loaded_model')
            model = load_model(model_path, compile=False)
            current_app.loaded_model = model
        print("Model loaded successfully")
        return 'Baseline model and train data successfully loaded'
    except requests.exceptions.RequestException as e:
        print(f"Error downloading model: {e}")
        return f'Error downloading model: {e}', 500
    except Exception as e:
        print(f"Error: {e}")
        return f'Error: {e}', 500

@app.route('/explain/combined', methods=['POST'])
def explain_shap_prediction():
    try:
        # get input data from the request
        data = request.get_json()
        print("Received input data for SHAP explanation")

        # Convert input data to the correct format for SHAP
        ecg_input = []

        for lead_name, lead_data in data['ecg'].items():
            ecg_input.append(lead_data)
        ecg_input = np.array(ecg_input).T.reshape((1, 5000, 12))
        print('Shape of ecg_input:', ecg_input.shape)

        # Creating DeepExplainer instance
        print("Initializing SHAP DeepExplainer...")
        explainer = DeepExplainer(current_app.loaded_model, current_app.train_ecg)
        print("DeepExplainer initialized successfully")

        # Calculating SHAP values
        print("Calculating SHAP values...")
        shap_values = explainer.shap_values(ecg_input)
        print("SHAP values calculated successfully")


        # Get the predicted disease index
        prediction = current_app.loaded_model.predict(ecg_input[:1])
        predicted_disease_index = np.argmax(prediction)
        print(f"Predicted disease index: {predicted_disease_index}")

        # Compute GradCAM heatmap
        heatmap = get_gradcam_heatmap(current_app.loaded_model, ecg_input[:1], predicted_disease_index)
        print("GradCAM heatmap generated with shape: ", heatmap.shape)
        heatmap_resized = zoom(heatmap, (5000 / heatmap.shape[0],))

        # Define a threshold for SHAP values to highlight important regions
        shap_threshold = np.percentile(shap_values[0][:, :, predicted_disease_index], 80)  # Top X% most important points
        print(f"SHAP threshold value: {shap_threshold}")

        # Filter SHAP values above the threshold for the predicted disease
        filtered_values = []
        percentage = 50
        model_leads = set()
        for lead in range(12):
            shap_vals_for_disease = shap_values[0][:, lead, predicted_disease_index]
            # Highlight regions where both SHAP and GradCAM agree
            agreement_mask = (shap_vals_for_disease > np.percentile(shap_vals_for_disease, percentage)) & (heatmap_resized > np.percentile(heatmap_resized, percentage))
            important_time_points = np.where(agreement_mask)[0] #get index values

            filtered_values.append({
                "lead": lead + 1,
                "important_time_points": important_time_points.tolist(),
            })

            if len(important_time_points) > 0:
                model_leads.add(lead_mapping[f'Lead {lead + 1}'])

        # Knowledge-base comparison
        labels_train = pd.read_csv('/home/swije/mysite/labels_train.csv')
        disease_code = labels_train.columns[predicted_disease_index]  # predicted index maps to a disease in the knowledge base

        doctor_criteria = knowledge_base.get(disease_code, None)
        model_leads = sorted(list(model_leads), key=lambda x: list(lead_mapping.values()).index(x))
        response_model_leads = sorted(
            [f"Lead {lead}" for lead in model_leads],
            key=lambda x: list(lead_mapping.values()).index(x.replace('Lead ', ''))
        )


        if not doctor_criteria:
            conclusion = f"Features for disease '{disease_code}' are not available. Hence conclusion cannot be provided"
            explanation_result = {
                "filtered_values": filtered_values,
                "disease": disease_code,
                "doctor_leads": "",
                "model_leads": response_model_leads,
                "conclusion": conclusion
            }
            return jsonify(explanation_result)

        doctor_leads = set(doctor_criteria.get('leads', [])) if doctor_criteria.get('leads') != 'all' else set(lead_mapping.values()) #set all leads if criteria is 'all'
        response_doctor_leads = sorted(list(doctor_leads), key=lambda x: list(lead_mapping.values()).index(x))

        matching_leads = doctor_leads.intersection(model_leads)
        doctor_leads_count = len(doctor_leads)
        matching_leads_count = len(matching_leads)

        # Results analysis with detailed reasoning
        if matching_leads_count == doctor_leads_count:
            conclusion = f"Accurate: All {matching_leads_count} out of {doctor_leads_count} leads focused."
        elif matching_leads_count >= 0.8 * doctor_leads_count:
            missing_leads = doctor_leads - model_leads
            conclusion = f"Mostly Accurate: {matching_leads_count} out of {doctor_leads_count} leads focused. Missing leads: {missing_leads}."
        elif matching_leads_count >= 0.5 * doctor_leads_count:
            missing_leads = doctor_leads - model_leads
            conclusion = f"Partially Accurate: {matching_leads_count} out of {doctor_leads_count} leads focused. Missing leads: {missing_leads}."
        elif matching_leads_count > 0:
            missing_leads = doctor_leads - model_leads
            conclusion = f"Needs Verification: {matching_leads_count} out of {doctor_leads_count} leads focused. Missing leads: {missing_leads}."
        else:
            conclusion = "Verification is advised: No leads focused."

        explanation_result = {
            "filtered_values": filtered_values,
            "disease": disease_code,
            "doctor_leads": list(response_doctor_leads),
            "model_leads": response_model_leads,
            "conclusion": conclusion
        }

        return jsonify(explanation_result)
    except Exception as e:
        print(f"Error during SHAP explanation: {e}")
        return f'Error during SHAP explanation: {e}', 500

if __name__ == "__main__":
    print("Starting Flask application...")
    app.run()

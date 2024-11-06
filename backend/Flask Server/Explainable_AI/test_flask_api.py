import os
import unittest
import json
from flask import Flask
from flask_app import app

class FlaskAPITestCase(unittest.TestCase):

    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
        self.app.get('/load/trainData')
        self.app.get('/load/model')

    def test_load_train_data(self):
        """Test if the /load/trainData endpoint correctly loads train data."""
        response = self.app.get('/load/trainData')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Train data successfully loaded', response.data)

    def test_load_model(self):
        """Test if the /load/model endpoint correctly loads the baseline model."""
        response = self.app.get('/load/model')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Baseline model and train data successfully loaded', response.data)

    def test_explain_shap_gradcam_prediction_normal_ecg(self):
        """Validate the /explain/combined endpoint for a sample Normal ECG input."""
        sample_data = {
            "ecg": {
                "l1": [0.1] * 5000,
                "l2": [0.2] * 5000,
                "l3": [0.3] * 5000,
                "avr": [0.4] * 5000,
                "avl": [0.5] * 5000,
                "avf": [0.6] * 5000,
                "v1": [0.7] * 5000,
                "v2": [0.8] * 5000,
                "v3": [0.9] * 5000,
                "v4": [1.0] * 5000,
                "v5": [1.1] * 5000,
                "v6": [1.2] * 5000
            }
        }
        response = self.app.post('/explain/combined', data=json.dumps(sample_data), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        response_data = json.loads(response.data)
        self.assertIn('filtered_values', response_data)
        self.assertIn('disease', response_data)
        self.assertIn('conclusion', response_data)

if __name__ == "__main__":
    unittest.main()

import 'package:cardiofitai/screens/common/dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/user_information_service.dart';

class DietaryPlanHomePage extends StatefulWidget {
  const DietaryPlanHomePage(this.user, {super.key});

  final User user;

  @override
  State<DietaryPlanHomePage> createState() => _DietaryPlanHomePageState();
}

class _DietaryPlanHomePageState extends State<DietaryPlanHomePage> {
  late QuerySnapshot<Object?> _userSignUpInfo;
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController sugarController = TextEditingController();
  String gender = 'Female';
  String cardiacCondition = 'No';
  String bmiResult = '';
  String bloodSugarResult = '';
  String cardiacConditionResult = 'No';
  String cholesterolResult = '';
  String ageRange = '';
  String advice = '';

  final Map<String, dynamic> dietAdvice = {
    '1-19': {
      'Female': {
        'Underweight': {
          'No': {
            'Normal': {
              'Normal':
                  'According to the information provided your BMI states your underweight,has no cardiac arrhythmia,blood cholestrol and blood sugar levels normal.\n You should focus on increasing caloric intake with balanced meals that include lean proteins, whole grains, healthy fats, and a variety of fruits and vegetables. \nIncorporating healthy snacks between meals, such as nuts, yogurt, or whole-grain products, can help boost calorie intake. \nIt`s essential to maintain a regular meal schedule and include energy-dense foods like avocados, nuts, seeds, and olive oil to promote healthy weight gain. While their current blood cholesterol and sugar levels are normal,\n it`s important to continue choosing foods that support cardiovascular health and stable blood sugar levels. Regular physical activity, such as strength training, can also support muscle growth and overall health.~Consume a balance diet diet',
              'Low':
                  'According to the information provided your BMI states your underweight,has no cardiac arrhythmia,blood blood sugar normal cholestrol sugar LOW.\n Focus on gaining weight and improving cholesterol levels through a nutrient-dense diet.\n You should consume a balanced diet rich in healthy fats, such as those found in avocados, nuts, seeds, and olive oil, which can help raise cholesterol to healthy levels. Including lean proteins, whole grains, and a variety of fruits and vegetables in their meals will provide the necessary nutrients to support overall health. Small, frequent meals and healthy snacks can help increase caloric intake.\n Regular monitoring of cholesterol levels is important to ensure they reach and maintain a healthy range.',
              'High':
                  'According to the information provided your BMI states your underweight,has no cardiac arrhythmia,blood blood sugar normal cholestrol sugar HIGH.\n Focus should on gaining weight in a healthy way while managing cholesterol levels. \n You should consume a balanced diet that is rich in lean proteins, whole grains, fruits, and vegetables, while limiting intake of saturated fats and cholesterol-rich foods. Healthy fats, such as those found in avocados, nuts, seeds, and olive oil, should be included, but foods high in trans fats and processed foods should be avoided. Small, frequent meals can help increase calorie intake without compromising cholesterol management.\n Regular physical activity, particularly aerobic exercises, can also help improve cholesterol levels while supporting healthy weight gain.',
            },
            'High': {
              'Normal':
                  'You are a female with age between 1-19, underweight according to BMI, no cardiac condition, high blood sugar, and normal cholesterol level:\n Focus on gaining weight through a balanced diet that includes lean proteins, whole grains, and healthy fats like avocados, nuts, and olive oil. It`s important to manage your high blood sugar by avoiding sugary foods and refined carbohydrates, instead opting for complex carbohydrates that provide sustained energy. Small, frequent meals throughout the day can help stabilize your blood sugar while promoting healthy weight gain.\nGet a balanced diet, Limit high sugary foods',
              'High':
                  'You are a female with age between 1-19, underweight according to BMI, no cardiac condition, high blood sugar, and high cholesterol level:\n To address both your high blood sugar and high cholesterol, it`s important to focus on nutrient-dense foods that are low in saturated fats and sugar. Incorporate lean proteins, whole grains, and a variety of fruits and vegetables into your meals. Limit foods high in cholesterol and trans fats, and opt for heart-healthy fats like those in nuts, seeds, and fish. Regular, balanced meals can help manage your blood sugar while supporting healthy weight gain and improving cholesterol levels.\nLimit high sugary foods, Limit deep fried foods',
              'Low':
                  'You are a female with age between 1-19, underweight according to BMI, no cardiac condition, high blood sugar, and low cholesterol level:\n Your diet should aim to increase your weight while managing high blood sugar and raising your cholesterol to a healthy level. Focus on eating nutrient-rich foods, including lean proteins, whole grains, and healthy fats such as avocados, nuts, and seeds. Avoid sugary foods and simple carbohydrates, and instead, choose complex carbohydrates and fiber-rich foods to stabilize your blood sugar. Small, frequent meals can help ensure adequate calorie intake and support healthy cholesterol levels.',
            },
            'Low': {
              'Normal':
                  'You are a female with age between 1-19, underweight according to BMI, no cardiac condition, low blood sugar, and normal cholesterol level: \nTo manage low blood sugar and promote weight gain, it’s important to eat frequent, balanced meals that include a mix of protein, complex carbohydrates, and healthy fats. Choose whole grains, lean proteins, and foods rich in healthy fats like nuts and avocados. These will provide sustained energy and help prevent blood sugar dips. Additionally, including small, healthy snacks between meals can help stabilize blood sugar and contribute to healthy weight gain.\nGet a balanced diet',
              'High':
                  'You are a female with age between 1-19, underweight according to BMI, no cardiac condition, low blood sugar, and high cholesterol level: \nYour diet should focus on increasing weight while managing cholesterol and preventing low blood sugar. Opt for nutrient-dense foods that include lean proteins, whole grains, and heart-healthy fats such as those in nuts, seeds, and avocados. Avoid foods high in saturated fats and simple sugars, and instead, choose complex carbohydrates to stabilize blood sugar levels. Eating small, frequent meals throughout the day can help maintain energy levels and improve overall health.\nGet a balanced diet, Limit high sugary foods',
              'Low':
                  'You are a female with age between 1-19, underweight according to BMI, no cardiac condition, low blood sugar, and low cholesterol level:\n Focus on a diet that supports weight gain and improves both blood sugar and cholesterol levels. Incorporate healthy fats, such as those in avocados, nuts, and olive oil, along with lean proteins and whole grains. Avoid sugary foods and simple carbohydrates, and instead, choose foods that provide sustained energy, such as complex carbohydrates and fiber-rich options. Regular, balanced meals with healthy snacks in between will help stabilize your blood sugar and promote a healthy increase in cholesterol levels.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'You are a female with age between 1-19, underweight according to BMI, present cardiac condition, high blood sugar, and normal cholesterol level\nBe aware of salt and fat intake, and limit high sugary foods to manage your high blood sugar. Focus on consuming nutrient-dense foods like lean proteins, whole grains, and healthy fats such as avocados, nuts, and olive oil. Regular meals with a balance of carbohydrates, proteins, and fats can help stabilize your blood sugar while supporting heart health.\nBe aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'You are a female with age between 1-19, underweight according to BMI, present cardiac condition, high blood sugar, and high cholesterol level:\nBe aware of salt intake, limit high sugary foods, and avoid deep-fried foods to manage both your high blood sugar and high cholesterol levels. Emphasize a diet rich in fruits, vegetables, whole grains, and lean proteins while incorporating heart-healthy fats like those found in fish, nuts, and olive oil. Regular, small meals can help you gain weight healthily without worsening cholesterol or blood sugar levels.\nBe aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low':
                  'You are a female with age between 1-19, underweight according to BMI, present cardiac condition, high blood sugar, and low cholesterol level:\nMeet a dietitian for personalized advice on how to raise your cholesterol to a healthy level while managing high blood sugar. Your diet should focus on increasing calorie intake with healthy fats, such as those found in avocados, nuts, and seeds, along with lean proteins and whole grains. Avoid sugary foods and focus on complex carbohydrates to help stabilize your blood sugar.\nMeet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Get a balanced diet',
            },
            'High': {
              'Normal': 'Get a balanced diet, Limit high sugary foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            }
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
      }, //0=19 Female
      'Male': {
        'Underweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
      },
    },
    '20-65': {
      'Female': {
        'Underweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High':
                  'You are a female with age between 20-65, Overweight according to BMI,No cardiac condition,low sugar but high cholestrol. Limit oily food and meet a dietitian as soon as possible to get a diet plan',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
      },
      'Male': {
        'Underweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
      },
    },
    '65+': {
      'Female': {
        'Underweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
      },
      'Male': {
        'Underweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Meet a dietitian',
              'High': 'Meet a dietitian',
              'Low': 'Meet a dietitian',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Meet a dietitian',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian',
            },
          },
        },
      },
    }, //65+
  };

  String categorizeBloodSugar(String testType, double sugar) {
    if (testType == 'Fasting') {
      if (sugar < 70) {
        return 'Low';
      } else if (sugar >= 70 && sugar <= 99) {
        return 'Normal';
      } else {
        return 'High'; // This includes both 'Prediabetes' and 'Diabetes'
      }
    } else if (testType == 'Random') {
      if (sugar < 140) {
        return 'Normal';
      } else {
        return 'High'; // This includes both 'Prediabetes' and 'Diabetes'
      }
    }
    return 'Unknown';
  }

  void provideDietAdvice() {
    int age = int.parse(ageController.text);
    String ageRange = '';
    if (age >= 1 && age <= 19) {
      // Fix: Change from <=19 to match '1-19'
      ageRange = '1-19';
    } else if (age >= 20 && age <= 65) {
      // Fix: Properly define the range for 20-65
      ageRange = '20-65';
    } else {
      ageRange = '65+';
    }
  }

  String categorizeBMI(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Normal';
    } else if (bmi >= 25.0 && bmi < 29.9) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  String categorizeCholesterol(double cholesterol) {
    if (cholesterol < 200) {
      return 'Low';
    } else if (cholesterol >= 200 && cholesterol <= 239) {
      return 'Normal';
    } else {
      return 'High';
    }
  }

  Future<void> _userInfo() async {
    _userSignUpInfo = await UserLoginService.getUserByEmail(widget.user.email);
    ageController.text = _userSignUpInfo.docs[0]["age"];
    bmiController.text = _userSignUpInfo.docs[0]["bmi"];
    cholesterolController.text =
        _userSignUpInfo.docs[0]["bloodCholestrolLevel"];
    sugarController.text = _userSignUpInfo.docs[0]["bloodGlucoseLevel"];
    gender = "Female"; //_userSignUpInfo.docs[0]["gender"];
    cardiacCondition = _userSignUpInfo.docs[0]["cardiacCondition"];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _userInfo();
  }

  void generatePrediction() {
    setState(() {
      double bmi = double.tryParse(bmiController.text) ?? 0.0;
      String bmiCategory = categorizeBMI(bmi);
      double cholesterol = double.tryParse(cholesterolController.text) ?? 0.0;
      cholesterolResult = categorizeCholesterol(cholesterol);
      double sugar = double.tryParse(sugarController.text) ?? 0.0;
      bloodSugarResult =
          categorizeBloodSugar('Fasting', sugar); // or 'Random', as needed

      int age = int.parse(ageController.text);
      if (age <= 19) {
        ageRange = '1-19';
      } else if (age <= 65) {
        ageRange = '20-65';
      } else {
        ageRange = '65+';
      }

      print('ageRange: $ageRange');
      print('gender: $gender');
      print('bmiCategory: $bmiCategory');
      print('cardiacCondition: $cardiacCondition');
      print('bloodSugarResult: $bloodSugarResult');
      print('cholesterolResult: $cholesterolResult');

      if (dietAdvice.containsKey(ageRange)) {
        if (dietAdvice[ageRange].containsKey(gender)) {
          if (dietAdvice[ageRange][gender].containsKey(bmiCategory)) {
            if (dietAdvice[ageRange][gender][bmiCategory]
                .containsKey(cardiacCondition)) {
              if (dietAdvice[ageRange][gender][bmiCategory][cardiacCondition]
                  .containsKey(bloodSugarResult)) {
                if (dietAdvice[ageRange][gender][bmiCategory][cardiacCondition]
                        [bloodSugarResult]
                    .containsKey(cholesterolResult)) {
                  advice = dietAdvice[ageRange][gender][bmiCategory]
                      [cardiacCondition][bloodSugarResult][cholesterolResult];
                } else {
                  advice =
                      'No advice available for the given cholesterol result';
                }
              } else {
                advice = 'No advice available for the given blood sugar result';
              }
            } else {
              advice = 'No advice available for the given cardiac condition';
            }
          } else {
            advice = 'No advice available for the given BMI category';
          }
        } else {
          advice = 'No advice available for the given gender';
        }
      } else {
        advice = 'No advice available for the given age range';
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          leading: IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DashboardScreen(widget.user)));
            },
          ),
          title: Align(
              alignment: Alignment.center,
              child: Text(
                'Customised Dietary Advice',
                style: TextStyle(color: Colors.white),
              )),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Confirm your data and click generate',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: gender,
                          onChanged: (String? newValue) {
                            setState(() {
                              gender = newValue!;
                            });
                          },
                          items: <String>['Female', 'Male']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: bmiController,
                decoration: InputDecoration(
                  labelText: 'BMI (kg/m²)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cholesterolController,
                      decoration: InputDecoration(
                        labelText: 'Blood Cholesterol Level',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: sugarController,
                      decoration: InputDecoration(
                        labelText: 'Blood Sugar Level',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'User have cardiac arrhythmia?',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: cardiacCondition,
                    onChanged: (String? newValue) {
                      setState(() {
                        cardiacCondition = newValue!;
                      });
                    },
                    items: <String>['No', 'Yes']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Align(
                  alignment: Alignment.centerRight,
                  // Aligns the button to the right
                  child: ElevatedButton(
                    onPressed: generatePrediction,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      // Text (foreground) color
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                      ),
                    ),
                    child: Text(
                      'Generate',
                      style: TextStyle(
                          fontSize: 16.0), // Adjust font size as needed
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                  'Dietary Advice given for a patient with following conditions is,',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text('BMI')),
                  Expanded(
                      child: Text(bmiController.text,
                          textAlign: TextAlign.center)),
                  Expanded(child: Text('Cardiac Condition')),
                  Expanded(
                      child: Text(cardiacConditionResult,
                          textAlign: TextAlign.center)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Blood Sugar Level')),
                  Expanded(
                      child:
                          Text(bloodSugarResult, textAlign: TextAlign.center)),
                  Expanded(child: Text('Blood Cholesterol Level')),
                  Expanded(
                      child:
                          Text(cholesterolResult, textAlign: TextAlign.center)),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  advice,
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
}

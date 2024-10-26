import 'package:cardiofitai/screens/common/dashboard_screen.dart';
import 'package:cardiofitai/screens/diet_plan/DietPlan/foodMenuScreen.dart';
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
              'Low': 'Focus on lean proteins, whole grains, fruits, vegetables, and heart-healthy fats. Ensure balanced meals, avoid excess salt, and prioritize hydration,for more guidance meet a dietitian',
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
              'Low': 'You are underweight according to BMI and with cardiac arrhythmia and low blood sugar and cholesterol, focus on frequent small meals rich in whole grains, lean proteins, fruits, and healthy fats - Meet a dietitian for more guidance',
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
              'Low': 'You are overweight with cardiac arrhythmia, high blood sugar, and low cholesterol: prioritize fiber-rich foods, lean proteins, whole grains, and limit sugar and processed carbs. Avoid trans fats.- Meet a dietitian for more guidance.',
            },
            'Low': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'You are overweight with cardiac arrhythmia, low blood sugar, and low cholesterol: eat whole grains, lean proteins, healthy fats, frequent small meals, and avoid sugary foods. Stay hydrated.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI states you`re overweight. Focus on whole grains, lean proteins, healthy fats like avocado, and plenty of vegetables. Avoid processed sugars, limit sodium, and eat small, frequent meals for heart health.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re overweight. Focus on fiber-rich foods, lean proteins, and healthy fats. Limit sugars, processed carbs, and sodium. Prioritize heart-healthy vegetables and small, balanced meals to manage sugar levels.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re overweight. Eat balanced meals with lean proteins, whole grains, and heart-healthy fats. Include frequent snacks to maintain blood sugar and avoid processed foods high in sodium.',
            }
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI states you`re obese. Focus on portion control, eat fiber-rich fruits, vegetables, lean proteins, and whole grains. Avoid sugary drinks and processed foods to maintain healthy cholesterol and weight.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re obese. Limit sugary foods, focus on whole grains, lean proteins, and healthy fats like avocado. Include fiber-rich vegetables and fruits, while avoiding processed foods to control blood sugar.',
            },
            'Low': {
              'Normal': 'Your BMI states you`re obese. Eat balanced meals rich in lean protein, whole grains, and healthy fats. Focus on complex carbs like sweet potatoes and whole grains to maintain stable blood sugar.',
              'High': 'MYour BMI states you`re obese. Limit saturated fats and cholesterol-rich foods. Focus on lean proteins, vegetables, and fiber-rich fruits. Include complex carbs and healthy fats like nuts and seeds for balanced blood sugar.',
              'Low': 'Your BMI states you`re obese. Increase intake of nutrient-dense foods like lean proteins, whole grains, and fiber-rich vegetables. Opt for healthy fats like olive oil and avocados to support blood sugar balance.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI states you`re obese. Focus on low-fat, high-fiber foods like vegetables, whole grains, and lean proteins to manage weight and support heart health. Avoid salty, processed foods',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re obese. Limit sugar, refined carbs, and processed foods. Emphasize vegetables, lean proteins, and whole grains to stabilize blood sugar and support heart health.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re obese. Focus on balanced meals with lean proteins, whole grains, and healthy fats to stabilize blood sugar and support heart health. Avoid sugary, processed, and high-salt foods.',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Your BMI states you`re perfect (normal). Focus on balanced meals rich in whole grains, lean proteins, and healthy fats. Continue to avoid processed and high-salt foods to maintain good health.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re perfect (normal). Focus on whole grains, lean proteins, and fiber-rich vegetables. Limit sugary foods and refined carbs to keep blood sugar levels stable and cholesterol low.',
            },
            'Low': {
              'Normal': 'Your BMI states you`re perfect (normal). Maintain your health with balanced meals including fruits, vegetables, lean proteins, and whole grains. Continue avoiding processed foods and excess sugars for long-term wellness.',
              'High': 'Your BMI states you`re perfect (normal). Focus on fiber-rich vegetables, lean proteins, and whole grains. Avoid sugary and high-fat foods to lower blood sugar and cholesterol, supporting overall heart health.',
              'Low': 'Your BMI states you`re perfect (normal). Eat regular meals with lean proteins, whole grains, and healthy fats to keep blood sugar stable. Avoid processed and sugary foods for heart and cholesterol health.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI states you`re perfect (normal). Focus on heart-friendly foods like whole grains, lean proteins, and healthy fats. Avoid high-salt, processed foods to maintain stable heart rhythms and cholesterol.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re perfect (normal). Prioritize heart-healthy foods, limit sugar and refined carbs, and include lean proteins and whole grains to manage blood sugar and support heart health.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re perfect (normal). Focus on balanced meals with lean proteins, whole grains, and healthy fats to stabilize blood sugar and support heart function. Avoid high-salt and sugary foods.',
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
              'Low': 'You1re underweight, so focus on nutrient-dense foods like lean proteins, whole grains, and healthy fats to promote healthy weight gain. Include foods that support low cholesterol, such as fatty fish, nuts, and seeds, while avoiding processed sugars and high-salt foods.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on gaining healthy weight by consuming nutrient-dense foods like lean proteins, whole grains, and healthy fats. Since your blood sugar is high, prioritize low-glycemic foods like vegetables, whole grains, and legumes, and avoid sugary snacks while including healthy fats like nuts and seeds to support cholesterol levels.',
            },
            'Low': {
              'Normal': 'Your BMI indicates that you`re underweight, so focus on calorie-dense, nutrient-rich foods like lean proteins, whole grains, and healthy fats to promote healthy weight gain. Since your blood sugar is low, eat frequent meals with complex carbohydrates (like whole grains and legumes) and healthy fats (like nuts and avocados) to maintain stable energy levels, while continuing a balanced diet to support overall health.',
              'High': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, high-calorie foods like lean proteins, whole grains, and healthy fats to promote weight gain. Since your blood sugar is low and cholesterol is high, prioritize low-glycemic, high-fiber foods (like vegetables and legumes) while incorporating healthy fats (like avocados and nuts) to help manage cholesterol, and avoid saturated fats and processed foods.',
              'Low': 'Your BMI indicates that you`re underweight, so focus on nutrient-rich foods like lean proteins, whole grains, and healthy fats to promote healthy weight gain. Since your blood sugar is low, eat frequent, balanced meals that include complex carbohydrates (like oats and whole grains) and healthy fats (like avocados and nuts) to stabilize blood sugar, while also including foods like fatty fish, seeds, and nuts to support low cholesterol.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on high-calorie, nutrient-dense foods like lean proteins, whole grains, and healthy fats to help gain weight. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats (like avocados, nuts, and olive oil), along with lean proteins and fiber-rich foods, while avoiding processed foods and high-sodium items to support heart health.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, high-calorie foods like lean proteins, whole grains, and healthy fats to support healthy weight gain. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize heart-healthy, low-glycemic foods such as vegetables, legumes, and whole grains, while including healthy fats like nuts and avocados, and avoid sugary and high-sodium processed foods to protect your heart and manage blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on high-calorie, nutrient-dense foods like lean proteins, whole grains, and healthy fats to promote healthy weight gain. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent meals with complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados and nuts) to stabilize blood sugar, while supporting heart health with heart-healthy fats and avoiding high-sodium processed foods.',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management by incorporating balanced meals with lean proteins, whole grains, and plenty of vegetables. Since your cholesterol is low, include heart-healthy fats like avocados, nuts, and olive oil, while avoiding processed foods and excessive sugary snacks to maintain stable blood sugar and support overall health.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management by prioritizing nutrient-dense, low-calorie foods like lean proteins, vegetables, and whole grains. Since your blood sugar is high and cholesterol is low, focus on low-glycemic foods (like whole grains and legumes) to help control blood sugar, while incorporating heart-healthy fats (like avocados, nuts, and seeds) to support cholesterol levels. Avoid processed foods, sugary snacks, and refined carbohydrates.',
            },
            'Low': {
              'Normal': 'Your BMI indicates that you`re overweight, so focus on weight management by eating nutrient-dense, lower-calorie foods like lean proteins, whole grains, and vegetables. Since your blood sugar is low, include complex carbohydrates (like oats and whole grains) and healthy fats (like avocados and nuts) in your meals to maintain stable energy levels, while continuing a balanced diet to support normal cholesterol levels. Avoid excessive sugary and high-fat foods.',
              'High': 'Your BMI indicates that you`re overweight, so focus on weight management by incorporating nutrient-dense, lower-calorie foods like lean proteins, whole grains, and vegetables. Since your blood sugar is low and cholesterol is high, include complex carbohydrates (like whole grains and legumes) and healthy fats (like nuts and seeds) to stabilize blood sugar, while avoiding saturated fats and processed foods to help lower cholesterol levels. Focus on heart-healthy fats, like olive oil and avocados, and reduce intake of sugary snacks and refined carbs.',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management by choosing nutrient-dense, lower-calorie foods like lean proteins, vegetables, and whole grains. Since your blood sugar is low and cholesterol is also low, eat frequent meals with complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados and nuts) to maintain stable blood sugar, while continuing a balanced diet to support overall health. Avoid processed foods and excessive sugary snacks.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on managing weight through a balanced diet that includes lean proteins, whole grains, and plenty of vegetables. Since your cholesterol is low, incorporate heart-healthy fats like avocados, nuts, and olive oil to support cholesterol levels. Continue to avoid processed and high-sugar foods to maintain stable blood sugar and promote overall health.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management by eating nutrient-dense, lower-calorie foods like lean proteins, vegetables, and whole grains. Since your blood sugar is high and cholesterol is low, prioritize low-glycemic foods like whole grains, legumes, and fiber-rich vegetables to help control blood sugar, while incorporating heart-healthy fats like avocados, nuts, and olive oil to support cholesterol levels. Avoid sugary snacks, refined carbohydrates, and processed foods.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on managing your weight by eating nutrient-dense, lower-calorie foods like lean proteins, whole grains, and vegetables. Since your blood sugar is low and cholesterol is low, include complex carbohydrates (like whole grains and legumes) and healthy fats (like nuts, seeds, and avocados) to stabilize blood sugar and support cholesterol levels. Avoid processed foods and sugary snacks while prioritizing balanced meals to maintain energy and overall health.',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet that emphasizes nutrient-dense foods like lean proteins, vegetables, and whole grains to support healthy weight loss. Since your cholesterol is low, include heart-healthy fats such as avocados, nuts, seeds, and olive oil. Avoid processed foods, sugary snacks, and refined carbohydrates while focusing on balanced meals to improve overall health and support sustainable weight management.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet rich in nutrient-dense foods like lean proteins, vegetables, and whole grains to support healthy weight loss. Since your blood sugar is high, prioritize low-glycemic foods such as whole grains, legumes, and fiber-rich vegetables to help manage blood sugar levels. To support low cholesterol, include heart-healthy fats like avocados, nuts, and olive oil while avoiding processed foods, sugary snacks, and refined carbohydrates.',
            },
            'Low': {
              'Normal': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, vegetables, and whole grains to aid in healthy weight loss. Since your blood sugar is low, include complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados and nuts) to maintain stable energy levels. With normal cholesterol, maintain a balanced diet and avoid processed foods, sugary snacks, and refined carbohydrates to support overall health and effective weight management.',
              'High': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet rich in nutrient-dense foods like lean proteins, vegetables, and whole grains to support weight loss. Since your blood sugar is low and cholesterol is high, include complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados, nuts, and olive oil) to stabilize blood sugar while avoiding saturated fats and processed foods to help lower cholesterol. Prioritize fiber-rich foods and avoid sugary snacks and refined carbohydrates to promote overall health.',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, vegetables, and whole grains to support healthy weight loss. Since your blood sugar is low and cholesterol is low, eat frequent meals with complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados, nuts, and seeds) to stabilize blood sugar and support cholesterol levels. Avoid processed foods and sugary snacks while focusing on balanced meals to improve overall health and manage weight effectively.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet rich in nutrient-dense foods like lean proteins, whole grains, and vegetables to promote weight loss. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats (like avocados, nuts, and olive oil), along with fiber-rich foods like vegetables and whole grains. Avoid processed foods, high-sodium items, and sugary snacks to support heart health and overall well-being.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled, nutrient-dense diet to promote weight loss, including lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, heart-healthy foods like vegetables, whole grains, and legumes to help control blood sugar. Incorporate healthy fats like avocados, nuts, and olive oil to support cholesterol levels, while avoiding processed foods, high-sodium items, and sugary snacks to protect your heart and manage blood sugar levels.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, vegetables, and whole grains to support healthy weight loss. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent meals rich in complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados, nuts, and olive oil) to stabilize blood sugar while supporting heart health and cholesterol levels. Avoid processed foods, sugary snacks, and high-sodium items to promote overall well-being and protect your heart.',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods.',
              'Low': 'Your BMI indicates that you`re perfectly fit, so focus on maintaining a balanced diet that includes lean proteins, whole grains, and a variety of fruits and vegetables to support overall health. Since your cholesterol is low, include heart-healthy fats like avocados, nuts, seeds, and olive oil, while continuing to avoid excessive processed foods and sugary snacks to maintain optimal cholesterol levels and long-term well-being.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re perfectly fit, so continue maintaining a balanced diet with lean proteins, whole grains, and plenty of vegetables. Since your blood sugar is high and cholesterol is low, focus on low-glycemic foods like whole grains, legumes, and fiber-rich vegetables to help control blood sugar. Include heart-healthy fats such as avocados, nuts, and olive oil to support cholesterol levels, while avoiding sugary snacks and processed foods.',
            },
            'Low': {
              'Normal': 'Your BMI indicates that you`re perfectly fit, so focus on maintaining a balanced diet with lean proteins, whole grains, and a variety of fruits and vegetables. Since your blood sugar is low, eat frequent meals with complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados and nuts) to stabilize blood sugar. With normal cholesterol, continue following a balanced diet while avoiding excessive sugary snacks and processed foods.',
              'High': 'Your BMI indicates that you`re perfectly fit, so focus on maintaining a balanced diet with lean proteins, whole grains, and vegetables. Since your blood sugar is low and cholesterol is high, eat frequent meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar, while incorporating heart-healthy fats like avocados, nuts, and olive oil. Avoid saturated fats and processed foods to help lower cholesterol, while prioritizing fiber-rich foods for overall heart health.',
              'Low': 'Your BMI indicates that you`re perfectly fit, so continue maintaining a balanced diet with lean proteins, whole grains, and a variety of vegetables and fruits. Since both your blood sugar and cholesterol are low, eat frequent meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar, and include healthy fats like avocados, nuts, and seeds to support cholesterol levels. Avoid processed foods and sugary snacks to maintain optimal overall health.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re perfectly fit, so focus on maintaining a balanced diet with lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels and heart health. Continue avoiding processed foods and excessive sugary snacks, while incorporating fiber-rich foods like fruits, vegetables, and whole grains to maintain overall health and support your heart.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re perfectly fit, so continue focusing on a balanced diet with lean proteins, whole grains, and vegetables. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic foods like whole grains, legumes, and fiber-rich vegetables to help control blood sugar. Include heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding processed foods, sugary snacks, and high-sodium items to protect your heart and manage blood sugar effectively.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re perfectly fit, so focus on maintaining a balanced diet with lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent meals with complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados, nuts, and olive oil) to stabilize blood sugar and support cholesterol levels. Avoid high-sodium and processed foods to protect your heart and promote overall health.',
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
              'Low': 'Your BMI states you`re underweight. Focus on nutrient-dense foods like nuts, avocados, lean proteins, and whole grains. Incorporate healthy fats to boost weight and cholesterol levels naturally.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re underweight. Include lean proteins, healthy fats, and fiber-rich carbs. Avoid sugary foods while eating calorie-dense, nutritious meals to manage blood sugar and improve cholesterol.',
            },
            'Low': {
              'Normal': 'Your BMI states you`re underweight. Focus on calorie-dense, fiber-rich foods like whole grains, lean proteins, and healthy fats. Limit sugary foods to manage blood sugar while maintaining balanced nutrition',
              'High': 'Your BMI states you`re underweight. Prioritize lean proteins, whole grains, and healthy fats. Avoid saturated fats while eating small, frequent meals to stabilize blood sugar and improve cholesterol levels.',
              'Low': 'Your BMI states you`re underweight. Eat small, frequent meals with lean proteins, whole grains, and healthy fats. Focus on nutrient-dense foods to stabilize blood sugar and increase cholesterol naturally.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI states you`re underweight. Focus on nutrient-dense foods like lean proteins, whole grains, and healthy fats. Avoid salty foods to support heart health and improve cholesterol levels.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re underweight. Emphasize fiber-rich foods, lean proteins, and healthy fats. Limit sugary foods to manage blood sugar while supporting heart health and raising cholesterol levels.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI states you`re underweight. Eat small, frequent meals rich in lean proteins, healthy fats, and whole grains. Stabilize blood sugar and improve cholesterol while avoiding processed and high-salt foods',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Meet a dietitian, Since your BMI state your overweight and has Low blood cholestrol level, design a diet plan matching to your medical reports',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian, Since your BMI state your overweight and has high blood sugar and low blood cholestrol, design a deit plan matching to your reports',
            },
            'Low': {
              'Normal': 'Meet a dietitian, Since your BMI state your overweight with low blood sugar, it is required for you to get medical help to make a diet plan',
              'High':
                  'You are a female with age between 20-65, Overweight according to BMI,No cardiac condition,low sugar but high cholestrol. Limit oily food and meet a dietitian as soon as possible to get a diet plan',
              'Low': 'Meet a dietitian, BMI with overweight and low cholestrol and low sugar level is quite abnormal, hence its better for you to get medicine experts help',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'You have a cardiac abnormality, your sugar level seems to be normal, but your cholestrol level is low, kindly Meet a dietitian to make a personalised healthy plan matching to your test results',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'You have a cardic abnormality plus high blood glucose level, your cholestrol level seems to be low, its high time for you to Meet a dietitian and choose a food pattern which aligns with your test results',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Meet a dietitian, since you have low sugar and low cholestrol levels its adviced to get experise help on this regard',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet rich in nutrient-dense foods like lean proteins, whole grains, and vegetables to support healthy weight loss. Since your blood sugar is normal and cholesterol is low, include heart-healthy fats like avocados, nuts, seeds, and olive oil to improve cholesterol levels. Avoid processed foods, sugary snacks, and refined carbohydrates, while ensuring a balanced intake of fiber-rich foods to promote overall health and maintain stable energy levels.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, whole grains, and plenty of vegetables to support healthy weight loss. Since your blood sugar is high and cholesterol is low, prioritize low-glycemic, high-fiber foods like whole grains, legumes, and vegetables to help manage blood sugar. Include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding processed foods, sugary snacks, and refined carbohydrates.',
            },
            'Low': {
              'Normal': 'Your BMI states you`re obese. Focus on lean proteins, whole grains, and healthy fats. Eat small, frequent meals to stabilize blood sugar and maintain cholesterol levels.',
              'High': 'Your BMI states you`re obese. Prioritize fiber-rich foods, lean proteins, and healthy fats. Avoid saturated fats to reduce cholesterol and eat frequent meals to manage blood sugar.',
              'Low': 'Your BMI states you`re obese. Focus on healthy fats, lean proteins, and whole grains. Eat regularly to stabilize blood sugar and incorporate nutrient-dense foods to boost cholesterol.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, whole grains, and vegetables to support healthy weight loss. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels and protect your heart. Include fiber-rich foods like vegetables, fruits, and legumes, and avoid processed foods, high-sodium items, and sugary snacks to maintain overall health and support heart function.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled, nutrient-dense diet to support healthy weight loss, including lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, heart-healthy foods such as vegetables, whole grains, and legumes to help manage blood sugar levels. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol, and avoid processed foods, sugary snacks, refined carbohydrates, and high-sodium items to protect your heart and stabilize blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled, nutrient-rich diet to support healthy weight loss, including lean proteins, whole grains, and vegetables. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent meals with complex carbohydrates (like whole grains and legumes) and heart-healthy fats (like avocados, nuts, and olive oil) to stabilize blood sugar and support cholesterol levels. Avoid high-sodium and processed foods to protect your heart, and include fiber-rich foods to promote overall health.',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Your BMI is perfect, so focus on maintaining a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Keep sodium intake low by avoiding processed foods and high-sodium snacks, and continue following a balanced, nutrient-rich diet to promote overall health and support heart function.',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI is perfect, so focus on maintaining a balanced diet that includes lean proteins, whole grains, and plenty of vegetables to support overall health.incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to help support cholesterol levels. Avoid processed foods, high-sodium items, and sugary snacks to protect your heart and promote long-term well-being.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is perfect, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables.Since you have high blood sugar, and low cholesterol, focus on low-glycemic, heart-healthy foods like whole grains, legumes, and fiber-rich vegetables to help manage blood sugar levels. Incorporate healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks, refined carbohydrates, and high-sodium processed foods to protect your heart and manage blood sugar.',
            },
            'Low': {
              'Normal': 'Your BMI is maintained perfectly. Focus on balanced meals with lean proteins, whole grains, and healthy fats. Eat small, frequent meals to stabilize blood sugar and maintain cholesterol levels.',
              'High': 'Your BMI is maintained perfectly. Prioritize fiber-rich foods, lean proteins, and healthy fats. Avoid saturated fats to lower cholesterol, while eating regularly to stabilize blood sugar',
              'Low': 'Your BMI is maintained perfectly. Focus on nutrient-dense meals with lean proteins, whole grains, and healthy fats. Eat frequently to stabilize blood sugar and boost cholesterol levels naturally.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI is perfect, so maintain a balanced diet with lean proteins, whole grains, and plenty of vegetables and fruits. Since you have a cardiac abnormality and low cholesterol, focus on incorporating heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods and high-sodium items to protect your heart, while continuing to follow a nutrient-rich, well-rounded diet to support overall health.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is perfect, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, focus on low-glycemic, heart-healthy foods like whole grains, legumes, and fiber-rich vegetables to help manage blood sugar levels. Incorporate healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks, refined carbohydrates, and high-sodium processed foods to protect your heart and manage blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is perfect, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, prioritize frequent meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar, and incorporate heart-healthy fats (like avocados, nuts, seeds, and olive oil) to support cholesterol levels. Avoid processed foods, sugary snacks, and high-sodium items to protect your heart and maintain overall health.',
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
              'Low': 'Your BMI indicates that you`re underweight, so focus on gaining healthy weight by incorporating nutrient-dense foods like lean proteins, whole grains, and healthy fats. Since your cholesterol is low, include heart-healthy fats such as avocados, nuts, seeds, and olive oil. To maintain normal blood sugar, eat balanced meals regularly, and avoid processed foods and sugary snacks while ensuring a diet rich in fruits, vegetables, and whole grains to promote overall health and gradual weight gain.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on gaining healthy weight with nutrient-dense foods like lean proteins, whole grains, and healthy fats. Since your blood sugar is high, prioritize low-glycemic foods such as whole grains, legumes, and fiber-rich vegetables to help control blood sugar. Include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, and avoid sugary snacks, processed foods, and refined carbohydrates. Focus on regular, balanced meals to promote gradual weight gain and overall health.',
            },
            'Low': {
              'Normal': 'Your BMI states you`re underweight. Focus on calorie-dense meals with healthy fats, lean proteins, and whole grains. Eat frequent meals to stabilize blood sugar and maintain cholesterol levels',
              'High': 'Your BMI states you`re underweight. Prioritize healthy fats, lean proteins, and fiber-rich foods. Avoid saturated fats, eat frequently to manage blood sugar, and focus on heart-healthy foods.',
              'Low': 'Your BMI states you`re underweight. Eat nutrient-rich meals with lean proteins, healthy fats, and whole grains. Increase meal frequency to stabilize blood sugar and raise cholesterol levels naturally',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, calorie-rich foods to promote healthy weight gain, such as lean proteins, whole grains, and healthy fats. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats like avocados, nuts, seeds, and olive oil. Eat balanced meals regularly to maintain stable blood sugar, and avoid processed foods and high-sodium items to protect your heart while supporting gradual weight gain and overall well-being.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on gaining healthy weight by incorporating nutrient-dense, calorie-rich foods such as lean proteins, whole grains, and healthy fats. Since you have a cardiac abnormality and high blood sugar, prioritize low-glycemic foods like vegetables, whole grains, and legumes to help manage blood sugar. Include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks, refined carbs, and high-sodium foods to protect your heart and stabilize blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, calorie-rich foods like lean proteins, whole grains, and healthy fats to promote healthy weight gain. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, prioritize frequent meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar. Include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding processed foods and high-sodium items to protect your heart.',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management by incorporating nutrient-dense, lower-calorie foods like lean proteins, vegetables, and whole grains. Since your cholesterol is low, include heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods, sugary snacks, and refined carbohydrates while emphasizing balanced meals to promote overall health and sustainable weight management.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management by choosing nutrient-dense, lower-calorie foods like lean proteins, vegetables, and whole grains. Since your blood sugar is high and cholesterol is low, prioritize low-glycemic foods (like whole grains, legumes, and fiber-rich vegetables) to help control blood sugar levels. Include heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol, while avoiding sugary snacks, refined carbohydrates, and processed foods for overall health.',
            },
            'Low': {
              'Normal': 'Your BMI states you`re overweight. Focus on lean proteins, whole grains, and vegetables. Eat small, frequent meals to stabilize blood sugar and maintain normal cholesterol levels',
              'High': 'Your BMI states you`re overweight. Prioritize fiber-rich foods, lean proteins, and healthy fats. Limit saturated fats to reduce cholesterol, and eat regularly to manage low blood sugar',
              'Low': 'Your BMI states you`re overweight. Eat nutrient-dense meals with lean proteins, whole grains, and healthy fats. Increase meal frequency to stabilize blood sugar and improve cholesterol levels..',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management with a balanced diet of nutrient-dense, lower-calorie foods like lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol and heart health. Avoid high-sodium and processed foods, while incorporating fiber-rich foods to support heart function and overall well-being.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management by incorporating nutrient-dense, lower-calorie foods like lean proteins, vegetables, and whole grains. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, heart-healthy foods such as whole grains, legumes, and fiber-rich vegetables to help manage blood sugar. Include healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks, refined carbohydrates, and high-sodium processed foods to protect your heart and promote overall health.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management by choosing nutrient-dense, lower-calorie foods like lean proteins, whole grains, and vegetables. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent meals with complex carbohydrates (like whole grains and legumes) to help stabilize blood sugar. Include heart-healthy fats, such as avocados, nuts, seeds, and olive oil, to support cholesterol levels and heart health, while avoiding high-sodium and processed foods to protect your heart.',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled, nutrient-rich diet to support healthy weight loss, including lean proteins, whole grains, and vegetables. Since your blood sugar is normal and cholesterol is low, incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods, sugary snacks, and refined carbohydrates, while prioritizing fiber-rich foods to promote overall health and sustain energy levels.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, vegetables, and whole grains to support weight loss. Since your blood sugar is high and cholesterol is low, prioritize low-glycemic, high-fiber foods like whole grains, legumes, and fiber-rich vegetables to help manage blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks, refined carbohydrates, and processed foods to promote overall health and effective weight management.',
            },
            'Low': {
              'Normal': 'Your BMI states you`re obese. Focus on lean proteins, whole grains, and healthy fats. Eat small, frequent meals to manage blood sugar and maintain your cholesterol at a healthy level.',
              'High': 'Your BMI states you`re obese. Focus on lean proteins, fiber-rich foods, and healthy fats. Avoid saturated fats to lower cholesterol, and eat more frequent meals to stabilize blood sugar.',
              'Low': 'Your BMI states you`re obese. Prioritize nutrient-dense meals with lean proteins, whole grains, and healthy fats. Eat frequent meals to stabilize blood sugar and improve cholesterol naturally',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet rich in nutrient-dense foods like lean proteins, whole grains, and vegetables to support healthy weight loss. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol and protect heart health. Avoid processed foods, high-sodium items, and sugary snacks, while emphasizing fiber-rich foods to support heart function and overall well-being.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-rich foods like lean proteins, vegetables, and whole grains to support weight loss. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, heart-healthy foods like whole grains, legumes, and fiber-rich vegetables to help manage blood sugar. Include heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks, refined carbohydrates, high-sodium foods, and processed items to protect your heart and promote balanced blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, vegetables, and whole grains to support healthy weight loss. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent, balanced meals that include complex carbohydrates (like whole grains and legumes) to stabilize blood sugar. Include heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding high-sodium and processed foods to protect your heart and maintain overall health.',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI is in a healthy range, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since your cholesterol is low, incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods and excessive sugary snacks, and continue prioritizing nutrient-dense meals to promote long-term health and wellness.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is in a healthy range, so maintain it with a balanced diet including lean proteins, whole grains, and plenty of vegetables. Since your blood sugar is high and cholesterol is low, focus on low-glycemic foods like whole grains, legumes, and fiber-rich vegetables to help manage blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks, refined carbs, and processed foods for overall wellness.',
            },
            'Low': {
              'Normal': 'Your BMI is maintained perfectly. Focus on balanced meals with whole grains, lean proteins, and healthy fats. Eat small, frequent meals to stabilize blood sugar and maintain your cholesterol.',
              'High': 'Your BMI is maintained perfectly. Focus on lean proteins, fiber-rich foods, and healthy fats. Limit saturated fats to reduce cholesterol and eat frequently to manage low blood sugar.',
              'Low': 'Your BMI is maintained perfectly. Prioritize nutrient-dense meals with lean proteins, whole grains, and healthy fats. Eat more frequent meals to stabilize blood sugar and improve cholesterol.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI is in a healthy range, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels and heart health. Avoid high-sodium and processed foods to protect your heart, and continue with nutrient-dense meals to promote long-term wellness.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is healthy, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, heart-healthy foods like whole grains, legumes, and fiber-rich vegetables to help control blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol, while avoiding sugary snacks, refined carbs, and high-sodium foods to protect your heart and promote balanced blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is healthy, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar, and incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid high-sodium and processed foods to protect your heart and promote overall well-being.',
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
              'Low': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, calorie-rich foods to promote healthy weight gain, including lean proteins, whole grains, and healthy fats. Since your cholesterol is low, incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Maintain regular, balanced meals to keep blood sugar stable, and prioritize foods rich in vitamins and minerals, like vegetables and fruits, to support overall health and strength as you age.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, calorie-rich foods to support healthy weight gain, including lean proteins, whole grains, and healthy fats. Since your blood sugar is high and cholesterol is low, prioritize low-glycemic foods like whole grains, legumes, and fiber-rich vegetables to help manage blood sugar. Incorporate heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks and refined carbs. Maintain balanced meals to promote steady energy and overall health.',
            },
            'Low': {
              'Normal': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, calorie-rich foods to support healthy weight gain, including lean proteins, whole grains, and healthy fats. Since your blood sugar is low, eat frequent, balanced meals with complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados, nuts, and seeds) to stabilize blood sugar. With normal cholesterol, continue to maintain a balanced diet, while avoiding processed foods and sugary snacks to support steady energy and overall health.',
              'High': 'Your BMI indicates that you`re underweight, so focus on gaining healthy weight by including nutrient-dense, calorie-rich foods like lean proteins, whole grains, and healthy fats. Since your blood sugar is high and cholesterol is also high, prioritize low-glycemic, high-fiber foods like vegetables, whole grains, and legumes to help control blood sugar and cholesterol levels. Incorporate heart-healthy fats, such as avocados, nuts, seeds, and olive oil, while avoiding sugary snacks, saturated fats, and processed foods to support heart health and manage blood sugar effectively.',
              'Low': 'Your BMI indicates that you`re underweight, so focus on gaining healthy weight with nutrient-dense, calorie-rich foods like lean proteins, whole grains, and healthy fats. Since both your blood sugar and cholesterol are low, eat frequent, balanced meals that include complex carbohydrates (like whole grains and legumes) to stabilize blood sugar, and heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods and sugary snacks, while prioritizing nutrient-rich meals to maintain steady energy and overall health.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, calorie-rich foods to promote healthy weight gain, such as lean proteins, whole grains, and healthy fats. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels and protect heart health. Maintain balanced meals with plenty of fiber-rich vegetables and whole grains, and avoid high-sodium and processed foods to support your heart and overall well-being.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on nutrient-dense, calorie-rich foods to help gain weight, including lean proteins, whole grains, and healthy fats. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, heart-healthy foods like vegetables, whole grains, and legumes to manage blood sugar levels. Include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol, while avoiding sugary snacks, refined carbs, and high-sodium foods to protect your heart and maintain steady blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re underweight, so focus on gaining healthy weight with nutrient-dense, calorie-rich foods such as lean proteins, whole grains, and healthy fats. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent, balanced meals that include complex carbohydrates (like whole grains and legumes) to help stabilize blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, and avoid high-sodium and processed foods to protect your heart.',
            },
          },
        },
        'Overweight': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management with a balanced, calorie-controlled diet that includes lean proteins, whole grains, and plenty of vegetables. Since your cholesterol is low, incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods, sugary snacks, and refined carbs, while prioritizing fiber-rich foods to maintain overall health and promote steady energy.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, whole grains, and plenty of vegetables to support weight management. Since your blood sugar is high and cholesterol is low, prioritize low-glycemic, high-fiber foods like whole grains, legumes, and fiber-rich vegetables to help control blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol, and avoid sugary snacks, refined carbohydrates, and processed foods to promote balanced blood sugar and overall wellness.',
            },
            'Low': {
              'Normal': 'Your BMI indicates that you`re overweight, so focus on a balanced, calorie-controlled diet with nutrient-rich foods like lean proteins, whole grains, and vegetables to support weight management. Since your blood sugar is low, incorporate complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados and nuts) in frequent meals to maintain stable energy levels. With normal cholesterol, continue prioritizing a balanced diet while avoiding processed foods and sugary snacks to promote overall health.',
              'High': 'Your BMI indicates that you`re overweight, so focus on weight management with a balanced, calorie-controlled diet that includes lean proteins, vegetables, and whole grains. Since your blood sugar is high and cholesterol is low, prioritize low-glycemic foods like whole grains, legumes, and fiber-rich vegetables to help control blood sugar. Include heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels, and avoid sugary snacks, refined carbs, and processed foods for optimal health.',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management with a nutrient-dense, calorie-controlled diet that includes lean proteins, whole grains, and plenty of vegetables. Since your blood sugar and cholesterol are both low, eat frequent, balanced meals that include complex carbohydrates (like whole grains and legumes) and heart-healthy fats (like avocados, nuts, and olive oil) to stabilize blood sugar and support cholesterol levels. Avoid sugary snacks, refined carbs, and processed foods to promote steady energy and overall health.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management with a balanced, calorie-controlled diet that includes lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol and protect heart health. Avoid high-sodium and processed foods, and incorporate fiber-rich foods such as fruits, vegetables, and whole grains to support your heart and overall well-being.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on a calorie-controlled, nutrient-dense diet to support healthy weight management, including lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, high-fiber foods such as whole grains, legumes, and fiber-rich vegetables to help manage blood sugar. Include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, and avoid sugary snacks, refined carbs, and high-sodium processed foods to protect your heart and stabilize blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re overweight, so focus on weight management with a balanced, calorie-controlled diet that includes lean proteins, whole grains, and vegetables. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent, balanced meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar. Incorporate heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid high-sodium, processed foods, and sugary snacks to protect your heart and promote steady energy levels and overall well-being.',
            },
          },
        },
        'Obese': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled, nutrient-dense diet to support healthy weight loss, including lean proteins, vegetables, and whole grains. Since your blood sugar is normal and cholesterol is low, include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods, sugary snacks, and refined carbs, and prioritize fiber-rich foods to promote steady energy, support heart health, and maintain overall well-being.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled, nutrient-rich diet to support healthy weight loss, emphasizing lean proteins, whole grains, and vegetables. Since your blood sugar is high and cholesterol is low, prioritize low-glycemic, high-fiber foods like legumes, whole grains, and fiber-rich vegetables to help manage blood sugar. Incorporate heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks, refined carbs, and processed foods to support heart health and stabilize blood sugar levels.',
            },
            'Low': {
              'Normal': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, whole grains, and plenty of vegetables to support healthy weight loss. Since your blood sugar is low, include frequent, balanced meals with complex carbohydrates (such as whole grains and legumes) to stabilize energy levels. With normal cholesterol, maintain heart-healthy fats like avocados, nuts, and olive oil, while avoiding processed foods and sugary snacks to support overall health and steady energy levels.',
              'High': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet with nutrient-dense foods like lean proteins, vegetables, and whole grains to support healthy weight loss. Since you have low blood sugar and high cholesterol, eat frequent, balanced meals with complex carbohydrates (such as whole grains and legumes) to stabilize blood sugar. Include heart-healthy fats like avocados, nuts, seeds, and olive oil, while avoiding saturated fats, sugary snacks, and processed foods to help lower cholesterol and promote heart health.',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet rich in nutrient-dense foods like lean proteins, vegetables, and whole grains to support healthy weight loss. Since both your blood sugar and cholesterol are low, eat frequent, balanced meals that include complex carbohydrates (such as whole grains and legumes) to help stabilize blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding processed foods and sugary snacks to promote steady energy and overall well-being.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet rich in nutrient-dense foods like lean proteins, whole grains, and vegetables to support healthy weight loss. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol and protect heart health. Avoid high-sodium, processed foods, and sugary snacks, while including fiber-rich foods like fruits, vegetables, and legumes to support heart function and promote overall well-being.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet filled with nutrient-dense foods like lean proteins, whole grains, and vegetables to promote healthy weight loss. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, high-fiber foods like whole grains, legumes, and fiber-rich vegetables to help manage blood sugar levels. Incorporate heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol, while avoiding sugary snacks, refined carbs, high-sodium, and processed foods to protect your heart and stabilize blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI indicates that you`re obese, so focus on a calorie-controlled diet rich in nutrient-dense foods like lean proteins, vegetables, and whole grains to support healthy weight loss. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, eat frequent, balanced meals with complex carbohydrates (such as whole grains and legumes) to stabilize blood sugar levels. Include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol, while avoiding high-sodium, processed foods, and sugary snacks to protect your heart and promote steady energy.',
            },
          },
        },
        'Normal': {
          'No': {
            'Normal': {
              'Normal': 'Get a balanced diet',
              'High': 'Get a balanced diet, Limit high sugary foods',
              'Low': 'Your BMI is in a healthy range, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels and heart health. Avoid high-sodium and processed foods to protect your heart, and continue with nutrient-dense meals to support overall well-being and long-term heart health.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is healthy, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, focus on low-glycemic, high-fiber foods like whole grains, legumes, and vegetables to help control blood sugar. Incorporate heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol, while avoiding sugary snacks, refined carbs, and high-sodium foods to protect your heart and manage blood sugar effectively.',
            },
            'Low': {
              'Normal': 'Your BMI is healthy, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since you have a cardiac abnormality and low blood sugar, prioritize frequent meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar. Continue incorporating heart-healthy fats, such as avocados, nuts, seeds, and olive oil, to support heart health, and avoid high-sodium and processed foods to protect your heart and promote steady energy.',
              'High': 'Your BMI is healthy, so maintain it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since you have a cardiac abnormality, low blood sugar, and high cholesterol, eat frequent, balanced meals with complex carbohydrates (such as whole grains and legumes) to help stabilize blood sugar. Focus on heart-healthy fats like avocados, nuts, and olive oil, while avoiding saturated fats and processed foods to help manage cholesterol levels and support heart health. Prioritize fiber-rich foods like fruits, vegetables, and whole grains for added cardiovascular support.',
              'Low': 'Your BMI is healthy, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables and fruits. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, focus on frequent, balanced meals that include complex carbohydrates (such as whole grains and legumes) to help stabilize blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding high-sodium and processed foods to protect your heart and maintain steady energy levels.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI is healthy, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since your cholesterol is low, incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods and excessive sugary snacks, and continue prioritizing nutrient-dense meals to support overall health and long-term wellness.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is healthy, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables. Since your blood sugar is high and cholesterol is low, focus on low-glycemic foods such as whole grains, legumes, and fiber-rich vegetables to help control blood sugar levels. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol, while avoiding sugary snacks, refined carbs, and processed foods for optimal health and blood sugar management.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is healthy, so continue maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since your blood sugar and cholesterol are both low, eat frequent, balanced meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding sugary snacks and processed foods to promote steady energy and overall wellness.',
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
              'Low': 'Since you have an underweight BMI, focus on nutrient-dense, calorie-rich foods to promote healthy weight gain, such as lean proteins, whole grains, and healthy fats. With low cholesterol, include heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Ensure regular, balanced meals to maintain stable blood sugar, and incorporate a variety of fruits and vegetables to provide essential vitamins and minerals, supporting overall health and gradual weight gain.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Since you have an underweight BMI, focus on nutrient-dense, calorie-rich foods to support healthy weight gain, including lean proteins, whole grains, and healthy fats. Given your high blood sugar and low cholesterol, prioritize low-glycemic foods like whole grains, legumes, and fiber-rich vegetables to help manage blood sugar levels. Incorporate heart-healthy fats, such as avocados, nuts, seeds, and olive oil, while avoiding sugary snacks, refined carbs, and processed foods to support stable blood sugar and promote gradual, healthy weight gain.',
            },
            'Low': {
              'Normal': 'Since you have an underweight BMI, focus on gaining healthy weight with nutrient-dense, calorie-rich foods such as lean proteins, whole grains, and healthy fats. Given your low blood sugar, eat frequent, balanced meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar levels. With normal cholesterol, continue to incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil, while avoiding sugary snacks and processed foods to promote steady energy and overall well-being.',
              'High': 'Since you have an underweight BMI, focus on nutrient-dense, calorie-rich foods to support healthy weight gain, including lean proteins, whole grains, and healthy fats. With low blood sugar and high cholesterol, prioritize frequent, balanced meals with complex carbohydrates (like whole grains and legumes) to help stabilize blood sugar. Incorporate heart-healthy fats, such as avocados, nuts, seeds, and olive oil, while avoiding saturated fats and processed foods to help manage cholesterol levels. Emphasize fiber-rich foods, like fruits, vegetables, and whole grains, to support heart health and steady energy levels.',
              'Low': 'Since you have an underweight BMI, focus on nutrient-dense, calorie-rich foods to support healthy weight gain, such as lean proteins, whole grains, and healthy fats. With low blood sugar and low cholesterol, eat frequent, balanced meals with complex carbohydrates (like whole grains and legumes) to stabilize blood sugar levels. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol, and avoid processed foods and sugary snacks to promote steady energy and overall wellness.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Since you have an underweight BMI, focus on gaining weight with nutrient-dense, calorie-rich foods like lean proteins, whole grains, and healthy fats. Given your cardiac abnormality and low cholesterol, incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol and heart health. Maintain regular, balanced meals with plenty of fiber-rich vegetables, whole grains, and lean proteins, while avoiding high-sodium and processed foods to protect your heart and promote steady weight gain.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Since you have an underweight BMI, focus on gaining weight with nutrient-dense, calorie-rich foods like lean proteins, whole grains, and healthy fats. Given your cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic foods such as whole grains, legumes, and fiber-rich vegetables to help manage blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid sugary snacks, refined carbs, and high-sodium foods to protect your heart and promote stable blood sugar while achieving healthy weight gain.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Since you have an underweight BMI, focus on gaining weight with nutrient-dense, calorie-rich foods like lean proteins, whole grains, and healthy fats. Given your cardiac abnormality, low blood sugar, and low cholesterol, eat frequent, balanced meals that include complex carbohydrates (like whole grains and legumes) to help stabilize blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels, while avoiding high-sodium and processed foods to protect your heart.',
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
              'Low': 'Your BMI is healthy, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since your cholesterol is low, incorporate heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol levels. Avoid processed foods and excessive sugary snacks, and continue prioritizing nutrient-dense, well-balanced meals to support long-term wellness and cardiovascular health.',
            },
            'High': {
              'Normal':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'High':
                  'Get a balanced diet, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is healthy, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables. Since your blood sugar is high and cholesterol is low, focus on low-glycemic, fiber-rich foods like whole grains, legumes, and vegetables to help manage blood sugar levels. Incorporate heart-healthy fats such as avocados, nuts, seeds, and olive oil to support cholesterol, and avoid sugary snacks, refined carbs, and processed foods to promote heart health and balanced blood sugar.',
            },
            'Low': {
              'Normal': 'Your BMI is healthy, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since your blood sugar is low, eat frequent, balanced meals with complex carbohydrates (like whole grains and legumes) and healthy fats (like avocados, nuts, and seeds) to maintain stable energy levels. With normal cholesterol, continue following a nutrient-rich diet while avoiding processed foods and sugary snacks to support overall wellness and steady blood sugar.',
              'High': 'Your BMI is healthy, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables and fruits. Since you have low blood sugar and high cholesterol, focus on frequent, balanced meals with complex carbohydrates (such as whole grains and legumes) to help stabilize blood sugar. Incorporate heart-healthy fats like avocados, nuts, seeds, and olive oil, while avoiding saturated fats, sugary snacks, and processed foods to help manage cholesterol levels and promote heart health. Prioritize fiber-rich foods, like fruits, vegetables, and whole grains, for added cardiovascular support.',
              'Low': 'Your BMI is healthy, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and a variety of vegetables and fruits. Since both your blood sugar and cholesterol are low, eat frequent, balanced meals that include complex carbohydrates (like whole grains and legumes) to help stabilize blood sugar. Include heart-healthy fats, such as avocados, nuts, seeds, and olive oil, to support cholesterol levels. Avoid processed foods and sugary snacks to maintain steady energy and promote overall well-being.',
            },
          },
          'Yes': {
            'Normal': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'Low': 'Your BMI is healthy, so maintain it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables and fruits. Since you have a cardiac abnormality and low cholesterol, prioritize heart-healthy fats like avocados, nuts, seeds, and olive oil to support cholesterol levels and promote heart health. Avoid high-sodium and processed foods, and continue focusing on fiber-rich foods like vegetables, legumes, and whole grains to support overall wellness and cardiovascular health.',
            },
            'High': {
              'Normal':
                  'Be aware of salt and fat intake, Limit high sugary foods',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is healthy, so maintain it with a balanced diet including lean proteins, whole grains, and plenty of vegetables and fruits. Since you have a cardiac abnormality, high blood sugar, and low cholesterol, prioritize low-glycemic, fiber-rich foods like whole grains, legumes, and vegetables to help control blood sugar. Incorporate heart-healthy fats, such as avocados, nuts, seeds, and olive oil, to support cholesterol levels and heart health. Avoid sugary snacks, refined carbs, and high-sodium processed foods to protect your heart and stabilize blood sugar.',
            },
            'Low': {
              'Normal': 'Be aware of salt and fat intake',
              'High':
                  'Be aware of salt intake, Limit high sugary foods, Limit deep fried foods',
              'Low': 'Your BMI is healthy, so focus on maintaining it with a balanced diet that includes lean proteins, whole grains, and plenty of vegetables and fruits. Since you have a cardiac abnormality, low blood sugar, and low cholesterol, prioritize frequent, balanced meals with complex carbohydrates (like whole grains and legumes) to help stabilize blood sugar. Include heart-healthy fats, such as avocados, nuts, seeds, and olive oil, to support cholesterol and heart health. Avoid high-sodium, processed foods, and sugary snacks to protect your heart and promote steady energy.',
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
                    onPressed:() {
                      generatePrediction();
                  },
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
              ElevatedButton(
                onPressed:() {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          FoodMenuScreen(widget.user)));
                },
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
                  'Suggested Recipes',
                  style: TextStyle(
                      fontSize: 16.0), // Adjust font size as needed
                ),
              )
            ],
          ),
        ),
      );
}

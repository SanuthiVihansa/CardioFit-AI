import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../components/navbar_component.dart';
import '../../../models/user.dart';
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
  String gender = '';
  String cardiacCondition = '';
  String bmiResult = '';
  String bloodSugarResult = '';
  String cardiacConditionResult = '';
  String cholesterolResult = '';
  String ageRange = '';
  String advice = '';

//Dictionary key for Diet advice proposal
  final Map<String, dynamic> dietAdvice = {
    '0-19': {
      'Female': {
        'Underweight': {
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
      }, //0-19 Male
      '18-65': {
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
      }, //18-65
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
    },
  };

  String categorizeBloodSugar(double sugar, String testType) {
    if (testType == 'Fasting') {
      if (sugar < 70) {
        return 'Low';
      } else if (sugar >= 70 && sugar <= 99) {
        return 'Normal';
      } else if (sugar >= 100 && sugar <= 125) {
        return 'Prediabetes';
      } else {
        return 'Diabetes';
      }
    } else if (testType == 'Random') {
      if (sugar < 140) {
        return 'Normal';
      } else if (sugar >= 140 && sugar <= 199) {
        return 'Prediabetes';
      } else {
        return 'Diabetes';
      }
    }
    return 'Unknown';
  }


  void provideDietAdvice() {
    int age = int.parse(ageController.text);
    String ageRange = '';
    if (age <= 19) {
      ageRange = '0-19';
    } else if (age <= 65) {
      ageRange = '18-65';
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
      return 'Desirable';
    } else if (cholesterol >= 200 && cholesterol <= 239) {
      return 'Borderline High';
    } else {
      return 'High';
    }
  }

  Future<void> _userInfo() async {
    _userSignUpInfo = await UserLoginService.getUserByEmail(widget.user.email);
    ageController.text = _userSignUpInfo.docs[0]["age"];
    bmiController.text = _userSignUpInfo.docs[0]["bmi"];
    cholesterolController.text = _userSignUpInfo.docs[0]["bloodCholestrolLevel"];
    sugarController.text = _userSignUpInfo.docs[0]["bloodGlucoseLevel"];
    gender=_userSignUpInfo.docs[0]["gender"];
    cardiacCondition=_userSignUpInfo.docs[0]["cardiacCondition"];
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
      bloodSugarResult = categorizeBloodSugar(sugar, 'Fasting'); // or 'Fasting', as needed

      try {
        int age = int.parse(ageController.text);
        if (age <= 19) {
          ageRange = '0-19';
        } else if (age <= 65) {
          ageRange = '18-65';
        } else {
          ageRange = '65+';
        }

        advice = dietAdvice[ageRange][gender][bmiCategory][cardiacCondition]
        [bloodSugarResult][cholesterolResult];
      } catch (e) {
        advice = 'No advice available for the given inputs';
      }
    });
  }


  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: LeftNavBar(
        user: widget.user,
        name: widget.user.name,
        email: widget.user.email,
        width: 150,
        height: 300),
    appBar: AppBar(
      title: Align(
          alignment: Alignment.center,
          child: Text('Customised Dietary Advice')),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Information',
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
              labelText: 'Cardiac Condition',
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
            child: ElevatedButton(
              onPressed: generatePrediction,
              child: Text('Generate'),
            ),
          ),
          SizedBox(height: 20),
          Text('Dietary Prediction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('BMI')),
              Expanded(child: Text(bmiController.text, textAlign: TextAlign.center)),
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
                  child: Text(bloodSugarResult, textAlign: TextAlign.center)),
              Expanded(child: Text('Blood Cholesterol Level')),
              Expanded(
                  child: Text(cholesterolResult, textAlign: TextAlign.center)),
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

const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "identityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "YOUR_POOL_ID",
            "AppClientId": "AKIAYS2NSR3OVX33HXYZ,
            "AppClientSecret": "UhvEuN1xRXdK8shCzXika+vnHbjARH1Db8VOMrbP",
            "Region": "ap-southeast-2"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH"
          }
        },
        "S3TransferUtility": {
          "Default": {
            "Bucket": "YOUR_BUCKET_NAME",
            "Region": "YOUR_REGION"
          }
        },
        "PinpointAnalytics": {
          "Default": {
            "AppId": "YOUR_PINPOINT_APP_ID",
            "Region": "YOUR_REGION"
          }
        },
        "PinpointTargeting": {
          "Default": {
            "Region": "YOUR_REGION"
          }
        }
      }
    }
  },
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "endpointType": "GraphQL",
        "endpoint": "YOUR_GRAPHQL_ENDPOINT",
        "region": "YOUR_REGION",
        "authorizationType": "AMAZON_COGNITO_USER_POOLS"
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "YOUR_BUCKET_NAME",
        "region": "YOUR_REGION"
      }
    }
  },
  "analytics": {
    "plugins": {
      "awsPinpointAnalyticsPlugin": {
        "appId": "YOUR_PINPOINT_APP_ID",
        "region": "YOUR_REGION"
      }
    }
  }
}''';

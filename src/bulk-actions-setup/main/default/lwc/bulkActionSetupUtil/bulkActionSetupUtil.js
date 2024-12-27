/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import LightningAlert from "lightning/alert";

const getConstants = () => {
  return {
    WARNING_THEME: "warning",
    WARNING_TITLE: "Action Enqueued",
    ERROR_THEME: "error",
    ERROR_THEME: "error",
    ACTION_STATUS_FLD: "actionStatus",
    ACTION_ERR_MSG_FLD: "actionErrorMessage",
    ERROR_MESSAGE: getErrorMessages(),
    STEPS: getSetupWizardSteps(),
    FLOWS: getFlowParameters()
  };
};

const getErrorMessages = () => {
  return {
    NO_RECORDS_MESSAGE: "No records were selected. Please select records.\n",
    NO_CONFIG_PASSED_MESSAGE:
      "No bulk action congfiguration name is passed. Please pass configuration name from list view button.\n",
    NO_BULK_ACTION_NAME: "Please populate bulk action name.\n",
    NO_PERM_SET_NAME: "Please populate permission set name.\n",
    NO_FIELD_SET: "Please populate field set name.\n",
    NO_EVAL_FLOW: "Please populate Evaluation Flow API Name.\n",
    NO_INPUT_FLOW: "Please populate Input Flow API Name.\n",
    NO_ACTION_FLOW: "Please populate Action Flow API Name.\n",
    NO_BULK_ACTION_OBJECT: "Please populate Object API Name.\n"
  };
};

const getSetupWizardSteps = () => {
  return {
    STEP: "Step",
    STEP1: "Step1",
    STEP2: "Step2",
    STEP3: "Step3",
    STEP4: "Step4",
    STEP5: "Step5",
    STEP6: "Step6"
  };
};

const getFlowParameters = () => {
  return {
    EVAL_FLOW: [
      {
        Name: "record",
        Type: "Record",
        IO: "",
        requiredIcon: "utility:check",
        inputIcon: "utility:arrowdown",
        Description:
          "This is the object record for which bulk action is defined, selected records are passed one by one to this variable."
      },
      {
        Name: "isValid",
        Type: "Boolean",
        requiredIcon: "utility:check",
        inputIcon: "utility:arrowup",
        Description:
          "This variable will be set to true if the record meets the criteria defined in a flow, create a boolean output variable with default value to false, use assignment block to set the variable to true if record meets the condition defined in a flow."
      }
    ],
    ACTION_FLOW: [
      {
        Name: "record",
        Type: "Record",
        IO: "",
        requiredIcon: "utility:check",
        inputIcon: "utility:arrowdown",
        Description:
          "This is the object record for which bulk action is defined, selected records are passed one by one to this variable."
      },
      {
        Name: "errorMessage",
        Type: "Text",
        requiredIcon: "utility:close",
        inputIcon: "utility:arrowup",
        Description:
          "This is an optional output variable, could be set to the action result or fault message."
      }
    ]
  };
};

export { getConstants };

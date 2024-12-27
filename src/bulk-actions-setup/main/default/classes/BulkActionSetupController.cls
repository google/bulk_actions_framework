/*
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

/**
 * @group: Controller
 * @description Contoller class for bulkActionSetup LWC
 */
public with sharing class BulkActionSetupController {
  private static final String BLANK = '';
  private static final String CONFIG_OBJ_NAME = 'Bulk_Action_Configuration__mdt';
  private static final String DIGITS = '[0-9]*';
  private static final String FORMAT = '{0}.{1}';
  private static final String REGEX_IGNORE_NUMBER_ALPHABETS = '[^a-zA-Z0-9]';
  private static final String SPACE = ' ';
  private static final String SPECIAL_CHARS = '[_+]';
  private static final String UNDERSCORE = '_';

  @TestVisible
  private static Id jobId;

  /**
   * @description creates a deployment container and initiates deployment for bulk action config record
   * @param config - Bulk_Action_Configuration__mdt config record
   * @return CustomMetadataCreateResult - metadata result wrapper
   */
  @AuraEnabled
  public static CustomMetadataCreateResult insertConfig(
    Bulk_Action_Configuration__mdt config
  ) {
    CustomMetadataCreateResult result = new CustomMetadataCreateResult();
    Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
    customMetadata.fullName = String.format(
      FORMAT,
      new List<String>{ CONFIG_OBJ_NAME, convertToAPIName(config.MasterLabel) }
    );
    customMetadata.Label = config.MasterLabel;

    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
      .get(CONFIG_OBJ_NAME)
      .getDescribe()
      .fields.getMap();

    for (String fieldName : fieldMap.keySet()) {
      Schema.DescribeFieldResult fieldRes = fieldMap.get(fieldName)
        .getDescribe();
      if (
        config.get(fieldRes.getName()) != null &&
        fieldRes.getName() != 'MasterLabel'
      ) {
        Metadata.CustomMetadataValue fieldData = new Metadata.CustomMetadataValue();
        fieldData.field = fieldRes.getName();
        fieldData.value = config.get(fieldRes.getName());
        customMetadata.values.add(fieldData);
      }
    }
    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(customMetadata);
    BulkActionCustomMetadataCallback callback = new BulkActionCustomMetadataCallback();
    try {
      jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
      result.jobId = jobId;
    } catch (AsyncException exp) {
      result.errorMessage.add(exp.getMessage());
      return result;
    }
    return result;
  }

  private static String convertToAPIName(String label) {
    String apiName = label.replaceFirst(DIGITS, BLANK)
      .replaceAll(REGEX_IGNORE_NUMBER_ALPHABETS, SPACE)
      .normalizeSpace()
      .replaceAll(SPACE, UNDERSCORE)
      .replaceAll(SPECIAL_CHARS, UNDERSCORE)
      .replaceFirst(DIGITS, BLANK);
    return apiName;
  }

  /**
   * @group: Struct
   * @description wrapper class for deployment result
   */
  public class CustomMetadataCreateResult {
    /**
     * @description deployment job id
     */
    @AuraEnabled
    public Id jobId { get; set; }
    /**
     * @description list of error messages
     */
    @AuraEnabled
    public List<String> errorMessage { get; set; }
    /**
     * @description deployment job status
     */
    @AuraEnabled
    public String status { get; set; }

    /**
     * @description constructor
     */
    public CustomMetadataCreateResult() {
      jobId = null;
      errorMessage = new List<String>();
    }
  }
}

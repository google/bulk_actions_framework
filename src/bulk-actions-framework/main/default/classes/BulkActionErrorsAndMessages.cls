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
 * @group: Constants
 * @description: Errors and UI Messages for bulk action framework
 */
@SuppressWarnings('PMD.AvoidDuplicateStrings')
public inherited sharing class BulkActionErrorsAndMessages {
  @TestVisible
  public static final String ERR_NO_FIELD_SET = '{0} bulk action configuration do not have field set populated. Please update configuration with field set api name.';
  @TestVisible
  public static final String ERR_NO_ACTION_FLOW = '{0} bulk action configuration do not have action flow populated. Please update configuration with action flow api name.';
  @TestVisible
  public static final String ERR_NO_CUSTOM_MESSAGE = '{0} bulk action configuration action flow is set to run in async mode. Please update configuration with field Custom Success Message.';
  @TestVisible
  public static final String ERR_NO_ACCESS_MESSAGE = 'You do not have permission to execute this action.';
  @TestVisible
  public static final String ERR_NO_CONFIG_MESSAGE = '{0} bulk action configuration action flow is set to run in async mode. Please update configuration with field Custom Success Message.';
  @TestVisible
  public static final String ERR_NO_CONFIG = 'Bulk action configuration not found with name configured in custom metadata. Please set bulk action configuration record developer name in the configuration.';
  @TestVisible
  public static final String INVALID_FLOW_VARIABLE = 'The {0} flow does not have a {1} variable called `{2}` that is available for output';
  @TestVisible
  public static final String NO_RECORDS_WITH_SAME_OBJECT = 'Selected records do not belong to same object. Please select records of single object.';
  @TestVisible
  public static final String OBJECT_FIELD_SET_NULL_ERROR = 'Object name or field set name should not be null.';
  @TestVisible
  public static final String FIELD_SET_ERROR = 'Fieldset with name {0} does not exist. Please set valid field set name in Bulk Actions Configuration metadata.';
}

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
 * @group Test
 * @description Tests for BulkActionCustomMetadataCallback
 */
@IsTest(isParallel=true)
private with sharing class BulkActionCustomMetadataCallbackTest {
  @IsTest
  private static void handleResultShouldReturnResultsOnSuccess() {
    Metadata.DeployResult result = new Metadata.DeployResult();
    result.status = Metadata.DeployStatus.Succeeded;
    Metadata.DeployMessage messageObj = new Metadata.DeployMessage();
    messageObj.changed = true;
    messageObj.success = true;
    messageObj.componentType = 'CustomMetadata';
    messageObj.fullName = 'Bulk_Action_Configuration__mdt.TestBA';
    Metadata.DeployDetails deployDetailsObj = new Metadata.DeployDetails();
    deployDetailsObj.componentSuccesses.add(messageObj);
    result.details = deployDetailsObj;
    Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();

    FakeSelectorBulkActionCustomMetadataCallback fakeSelector = new FakeSelectorBulkActionCustomMetadataCallback(
      new User(Email = 'test@test.com')
    );
    BulkActionCustomMetadataCallback.selector = fakeSelector;

    BulkActionCustomMetadataCallback callback = new BulkActionCustomMetadataCallback();

    callback.handleResult(result, context);

    System.assertEquals(
      BulkActionCustomMetadataCallback.SUBJECT_SUCCESS,
      callback.subject,
      'Method should handle success result'
    );
  }

  @IsTest
  private static void handleResultShouldReturnResultsOnError() {
    BulkActionCustomMetadataCallback callback = new BulkActionCustomMetadataCallback();
    Metadata.DeployResult result = new Metadata.DeployResult();
    result.status = Metadata.DeployStatus.Failed;
    Metadata.DeployMessage messageObj = new Metadata.DeployMessage();
    messageObj.changed = false;
    messageObj.success = false;
    messageObj.componentType = 'CustomMetadata';
    messageObj.fullName = 'Bulk_Action_Configuration__mdt.TestBA';
    messageOBj.problem = 'Default: value not of required type: 1';
    messageObj.problemType = Metadata.DeployProblemType.Error;
    Metadata.DeployDetails deployDetailsObj = new Metadata.DeployDetails();
    deployDetailsObj.componentFailures.add(messageObj);
    result.details = deployDetailsObj;
    Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();

    FakeSelectorBulkActionCustomMetadataCallback fakeSelector = new FakeSelectorBulkActionCustomMetadataCallback(
      new User(Email = 'test@test.com')
    );
    BulkActionCustomMetadataCallback.selector = fakeSelector;

    callback.handleResult(result, context);

    System.assertEquals(
      BulkActionCustomMetadataCallback.SUBJECT_FAILURE,
      callback.subject,
      'Method should handle error result'
    );
  }

  private inherited sharing class FakeSelectorBulkActionCustomMetadataCallback extends BulkActionCustomMetadataCallback.Selector {
    public User usr;

    /**
     * @description constructor for setting up return values
     * @param usr - user record to return
     */
    public FakeSelectorBulkActionCustomMetadataCallback(User usr) {
      this.usr = usr;
    }
    /**
     * @description fake selector to return user details
     * @param userId - userId
     * @return User - user details for given user id
     */
    public override User getUserDetails(Id userId) {
      return this.usr;
    }
  }
}

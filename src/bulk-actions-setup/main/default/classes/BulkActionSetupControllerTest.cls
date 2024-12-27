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
 * @group: Test
 * @description Test class for BulkActionSetupController
 */
@IsTest(isParallel=true)
private with sharing class BulkActionSetupControllerTest {
  @IsTest
  private static void insertConfigShouldThrowException() {
    Bulk_Action_Configuration__mdt conf = new Bulk_Action_Configuration__mdt();
    conf.MasterLabel = 'Test';

    BulkActionSetupController.CustomMetadataCreateResult result = BulkActionSetupController.insertConfig(
      conf
    );

    System.assertEquals(
      true,
      result.errorMessage.size() > 0,
      'Exception should be thrown if tried to deployed from test class'
    );
    System.assertEquals(
      'Metadata cannot be deployed from within a test',
      result.errorMessage[0],
      'Exception should be thrown if tried to deployed from test class'
    );
  }
}

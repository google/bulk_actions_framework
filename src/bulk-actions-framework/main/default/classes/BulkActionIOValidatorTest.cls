/**
 * @group Test
 * @description Tests for BulkActionIOValidator
 */
@IsTest(isParallel=true)
private with sharing class BulkActionIOValidatorTest {
  private static final String FLOW_API_NAME = 'Test Flow';

  //Data Setup
  private static Bulk_Action_Configuration__mdt config = BulkActionsTestDataUtil.getConfig();
  private static Case sampleCase = BulkActionsTestDataUtil.getSampleCase();
  private static Contact sampleContact = BulkActionsTestDataUtil.getSampleContact();
  private static Invocable.Action.Result evalFlowSuccessResult = BulkActionsTestDataUtil.getValidInvocableResult();
  private static Invocable.Action.Result evalFlowErrorResultInvalidOutputIsValid = BulkActionsTestDataUtil.getInvalidInvocableResultForIsValidFlag();
  private static Invocable.Action.Result evalFlowErrorResultInvalidOutputMessage = BulkActionsTestDataUtil.getInvalidInvocableResultForOutputMessageVar();

  @IsTest
  private static void validateConfigurationShouldThrowErrorOnMissingPreviewFS() {
    config.Preview_Screen_Field_Set_API_Name__c = null;
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.ERR_NO_FIELD_SET,
        new List<String>{ config.MasterLabel }
      ),
      BulkActionIOValidator.hasPreviewFieldSet(config),
      'Config validation should throw error on missing preview fiescreen field set'
    );
  }

  @IsTest
  private static void validateConfigurationShouldThrowErrorOnMissingActFlow() {
    config.Action_Flow_API_Name__c = null;
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.ERR_NO_ACTION_FLOW,
        new List<String>{ config.MasterLabel }
      ),
      BulkActionIOValidator.hasActionFlow(config),
      'Config validation should throw error on missing action flow'
    );
  }

  @IsTest
  private static void validateConfigurationShouldThrowErrorOnMissingCustMsg() {
    config.Is_Action_Flow_Execution_in_Async_Mode__c = true;
    config.Custom_Success_Message__c = null;
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.ERR_NO_CONFIG_MESSAGE,
        new List<String>{ config.MasterLabel }
      ),
      BulkActionIOValidator.hasCustomMessage(config),
      'Config validation should throw error on missing custom message'
    );
  }

  @IsTest
  private static void validateEvalFlowParamentersShouldNotThrowExceptionOnValidPara() {
    Boolean isException = false;
    try {
      BulkActionIOValidator.validateEvalFlowParamenters(
        evalFlowSuccessResult,
        FLOW_API_NAME
      );
    } catch (IllegalArgumentException ex) {
      isException = true;
    }
    System.assertEquals(
      isException,
      false,
      'Exception should not be generated on valid input'
    );
  }

  @IsTest
  private static void validateEvalFlowParamentersShouldThrowExInvalidOutputIsValid() {
    String exMessage;
    try {
      BulkActionIOValidator.validateEvalFlowParamenters(
        evalFlowErrorResultInvalidOutputIsValid,
        FLOW_API_NAME
      );
    } catch (IllegalArgumentException ex) {
      exMessage = ex.getMessage();
    }
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.INVALID_FLOW_VARIABLE,
        new List<String>{
          FLOW_API_NAME,
          BulkActionIOValidator.EVAL_FLOW_PARA_MAP.get(
              BulkActionConstants.FLOW_VAR_REQUIRED
            )
            .get(BulkActionConstants.EVAL_FLOW_OP_IS_VALID),
          BulkActionConstants.EVAL_FLOW_OP_IS_VALID
        }
      ),
      exMessage,
      'System should throw exception on invalid output variables'
    );
  }

  @IsTest
  private static void validateEvalFlowParamentersShouldThrowExInvalidOutputMessage() {
    String exMessage;
    try {
      BulkActionIOValidator.validateEvalFlowParamenters(
        evalFlowErrorResultInvalidOutputMessage,
        FLOW_API_NAME
      );
    } catch (IllegalArgumentException ex) {
      exMessage = ex.getMessage();
    }
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.INVALID_FLOW_VARIABLE,
        new List<String>{
          FLOW_API_NAME,
          BulkActionIOValidator.EVAL_FLOW_PARA_MAP.get(
              BulkActionConstants.FLOW_VAR_OPTIONAL
            )
            .get(BulkActionConstants.EVAL_FLOW_OP_MSG),
          BulkActionConstants.EVAL_FLOW_OP_MSG
        }
      ),
      exMessage,
      'System should throw exception on invalid output variables'
    );
  }

  @IsTest
  private static void checkSelectedRecordsBelongsToSameObjShouldCheckRecords() {
    String exMessage;
    try {
      BulkActionIOValidator.checkSelectedRecordsBelongsToSameObj(
        new List<Id>{ sampleContact.Id, sampleCase.Id }
      );
    } catch (BulkActionsException ex) {
      exMessage = ex.getMessage();
    }
    System.assertEquals(
      BulkActionErrorsAndMessages.NO_RECORDS_WITH_SAME_OBJECT,
      exMessage,
      'System should throw exception on records selected from diffrent objects'
    );
  }
}

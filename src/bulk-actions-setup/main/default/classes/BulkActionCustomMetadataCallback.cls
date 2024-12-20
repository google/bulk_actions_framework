/**
 * @group: Callback
 * @description Callback class for custom metadata insertion
 */
public with sharing class BulkActionCustomMetadataCallback implements Metadata.DeployCallback {
  private static final String BODY_FAILURE = 'Error while creating a record {0} with problem {1}';
  private static final String BODY_SUCCESS = 'Bulk Action configuration - {0} created successfully.';
  @TestVisible
  private static final String SUBJECT_FAILURE = 'Bulk Action Configuration Creation Failed';
  @TestVisible
  private static final String SUBJECT_SUCCESS = 'Custom metadata for Bulk Action configuration created successfully';

  @TestVisible
  private static BulkActionCustomMetadataCallback.Selector selector = new BulkActionCustomMetadataCallback.Selector();

  private String body;
  @TestVisible
  private String subject;

  /**
   * @description handles result for async deployment, post processing result is communicated to user
   * @param result - deployment result
   * @param context - deployment callback context for triggered deplyment
   */
  public void handleResult(
    Metadata.DeployResult result,
    Metadata.DeployCallbackContext context
  ) {
    User deploymentUser = selector.getUserDetails(result.createdBy);
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.setToAddresses(new List<String>{ deploymentUser.Email });
    if (result.status == Metadata.DeployStatus.Succeeded) {
      subject = SUBJECT_SUCCESS;
      body = String.format(
        BODY_SUCCESS,
        new List<String>{ result.details.componentSuccesses[0].fullName }
      );
    } else {
      subject = SUBJECT_FAILURE;
      body = String.format(
        BODY_FAILURE,
        new List<String>{
          result.details.componentFailures[0]?.fullName,
          result.details.componentFailures[0]?.problem
        }
      );
    }
    message.setSubject(subject);
    message.setPlainTextBody(body);
    mails.add(message);
    Messaging.sendEmail(mails, false);
  }

  @TestVisible
  private virtual inherited sharing class Selector {
    /**
     * @description returns user details by userId
     * @param userId - id of the user who triggered deployment
     * @return User - record by user id
     */
    public virtual User getUserDetails(Id userId) {
      return [SELECT UserName, Email FROM User WHERE Id = :userId];
    }
  }
}

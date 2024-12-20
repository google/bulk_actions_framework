/**
 * @group: Constants
 * @description: Constants for bulk action framework
 */
public with sharing class BulkActionConstants {
  public static final String ERROR = 'Error';
  public static final String INPROGRESS = 'Pending';
  public static final String SUCCESS = 'Success';
  public static final String FLOW_VAR_REQUIRED = 'required';
  public static final String FLOW_VAR_OPTIONAL = 'optional';
  public static final String EVAL_FLOW_OP_IS_VALID = 'isValid';
  public static final String EVAL_FLOW_OP_MSG = 'outputMessage';
  public static final String DTYPE_BOOL = 'Boolean';
  public static final String DTYPE_STR = 'String';
  public static final String RECORD_VARIABLE = 'record';
  public static final String FLOW_TYPE_EVAL = 'Evaluation';
  public static final String FLOW_TYPE_ACTION = 'Action';
  public static final String UNDERSCORE_R = '__r';
  public static final String UNDERSCORE_C = '__c';
  public static final String ID = 'Id';
  public static final String DOT = '.';
  public static final String DISPLAY_TEXT = 'text';
  public static final String DISPLAY_NUMBER = 'number';
  public static final String RET_URL =
    URL.getOrgDomainUrl().toExternalForm() + '/lightning/o/{0}/list';
  //map to store dataType values vs data table column type values
  @TestVisible
  public static final Map<Schema.DisplayType, String> DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP = new Map<Schema.DisplayType, String>{
    Schema.DisplayType.address => DISPLAY_TEXT,
    Schema.DisplayType.anytype => DISPLAY_TEXT,
    Schema.DisplayType.base64 => DISPLAY_TEXT,
    Schema.DisplayType.Boolean => 'boolean',
    Schema.DisplayType.Combobox => DISPLAY_TEXT,
    Schema.DisplayType.Currency => 'currency',
    Schema.DisplayType.Date => 'date-local',
    Schema.DisplayType.DateTime => 'date',
    Schema.DisplayType.Double => DISPLAY_NUMBER,
    Schema.DisplayType.Email => 'email',
    Schema.DisplayType.EncryptedString => DISPLAY_TEXT,
    Schema.DisplayType.Long => DISPLAY_NUMBER,
    Schema.DisplayType.Location => 'location',
    Schema.DisplayType.ID => DISPLAY_TEXT,
    Schema.DisplayType.Integer => DISPLAY_NUMBER,
    Schema.DisplayType.MultiPicklist => DISPLAY_TEXT,
    Schema.DisplayType.Percent => 'percent',
    Schema.DisplayType.Phone => 'phone',
    Schema.DisplayType.Picklist => 'picklist',
    Schema.DisplayType.Reference => 'lookup',
    Schema.DisplayType.String => DISPLAY_TEXT,
    Schema.DisplayType.TextArea => DISPLAY_TEXT,
    Schema.DisplayType.Time => DISPLAY_TEXT,
    Schema.DisplayType.URL => 'url'
  };
}

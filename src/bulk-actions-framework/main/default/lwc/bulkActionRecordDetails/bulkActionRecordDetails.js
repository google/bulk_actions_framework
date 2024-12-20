import { LightningElement, api } from "lwc";
import { getConstants } from "c/bulkActionUtil";

//constants
const CONSTANTS = getConstants();

export default class BulkActionRecordDetails extends LightningElement {
  @api columns;
  @api rows;
  @api tableType;
  @api message;

  helpText = "";
  hasRendered = false;
  errorMessage;

  renderedCallback() {
    if (!this.hasRendered) {
      this.sendHelpText();
      this.hasRendered = true;
    }
  }

  get formattedColumns() {
    let columns = [];
    columns.push(CONSTANTS.RECORD_DETAIL_LINK_COLUMN);
    for (const col of this.columns) {
      if (col.helpText) {
        this.helpText += `<b>${col.label}</b> - ${col.helpText}<br/><br/>`;
      }
      columns.push({
        label: col.label,
        type: col.fieldDataType,
        fieldName: col.apiName
      });
    }
    if (this.tableType === CONSTANTS.TABLE.ACTION_RESULT.LABEL) {
      columns.push(CONSTANTS.ACTION_COLUMN);
    }
    return columns;
  }

  get showTable() {
    return this.rows.length > 0;
  }

  get showHelpText() {
    return this.tableType === CONSTANTS.TABLE.ELIGIBLE_RECORDS;
  }

  get headerTitle() {
    if (this.tableType === CONSTANTS.TABLE.ELIGIBLE_RECORDS.LABEL) {
      return CONSTANTS.TABLE.ELIGIBLE_RECORDS.HEADER;
    } else if (this.tableType === CONSTANTS.TABLE.NON_ELIGIBLE_RECORDS.LABEL) {
      return CONSTANTS.TABLE.NON_ELIGIBLE_RECORDS.HEADER;
    } else if (this.tableType === CONSTANTS.TABLE.ACTION_RESULT.LABEL) {
      return CONSTANTS.TABLE.ACTION_RESULT.HEADER;
    }
  }

  get headerIcon() {
    if (this.tableType === CONSTANTS.TABLE.ELIGIBLE_RECORDS.LABEL) {
      return CONSTANTS.TABLE.ELIGIBLE_RECORDS.ICON;
    } else if (this.tableType === CONSTANTS.TABLE.NON_ELIGIBLE_RECORDS.LABEL) {
      return CONSTANTS.TABLE.NON_ELIGIBLE_RECORDS.ICON;
    } else if (this.tableType === CONSTANTS.TABLE.ACTION_RESULT.LABEL) {
      return CONSTANTS.TABLE.ACTION_RESULT.ICON;
    }
  }

  get iconClass() {
    if (this.tableType === CONSTANTS.TABLE.ELIGIBLE_RECORDS.LABEL) {
      return CONSTANTS.TABLE.ELIGIBLE_RECORDS.CLASS;
    } else if (this.tableType === CONSTANTS.TABLE.NON_ELIGIBLE_RECORDS.LABEL) {
      return CONSTANTS.TABLE.NON_ELIGIBLE_RECORDS.CLASS;
    } else if (this.tableType === CONSTANTS.TABLE.ACTION_RESULT.LABEL) {
      return CONSTANTS.TABLE.ACTION_RESULT.CLASS;
    }
  }

  get formattedRows() {
    let result = [];
    for (const row of this.rows) {
      const finalSobjectRow = {};
      let rowIndexes = Object.keys(row);
      rowIndexes.forEach((rowIndex) => {
        const relatedFieldValue = row[rowIndex];
        if (relatedFieldValue?.constructor === Object) {
          this.parseLookupValues(relatedFieldValue, finalSobjectRow, rowIndex);
        } else {
          finalSobjectRow[rowIndex] = relatedFieldValue;
        }
      });
      let record = { ...finalSobjectRow, link: "/" + finalSobjectRow.Id };
      result.push(record);
    }
    return result;
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "viewError":
        this.errorMessage = row.actionErrorMessage;
        break;
      default:
    }
  }

  parseLookupValues = (fieldValue, finalSobjectRow, fieldName) => {
    let rowIndexes = Object.keys(fieldValue);
    rowIndexes.forEach((key) => {
      let finalKey = fieldName + "." + key;
      finalSobjectRow[finalKey] = fieldValue[key];
    });
  };

  sendHelpText() {
    this.dispatchEvent(
      new CustomEvent("loadhelptext", {
        detail: {
          helpText: this.helpText
        }
      })
    );
  }
}

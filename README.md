# Bulk Actions Framework

This is not an officially supported Google product. This project is not
eligible for the [Google Open Source Software Vulnerability Rewards
Program](https://bughunters.google.com/open-source-security).

**Overview**

The Bulk Actions Framework is a solution designed to streamline and simplify the process of performing the same action on multiple records simultaneously. It addresses the common business requirement of taking bulk actions, such as updating fields, creating tasks, or sending emails, on multiple records at once.

**Key Benefits**

- **Efficiency:** Significantly reduces the development and deployment time required for implementing bulk actions.
- **Standardization:** Provides a unified and configurable framework for handling various bulk action scenarios.
- **Flexibility:** Allows developers to define custom evaluation criteria, input flows, and action flows to tailor the framework to specific use cases.

**How It Works**

1.  **Trigger:** A user initiates a bulk action from a list view button, selecting the records they want to apply the action to.
2.  **Initialization:** A generic "screen" flow is invoked, passing the configuration name for the specific bulk action.
3.  **Evaluation (Optional):** An evaluation flow can be configured to filter the selected records based on specific criteria, ensuring that only eligible records are processed.
4.  **Input (Optional):** An input flow can be used to gather additional information from the user before executing the action.
5.  **Action:** The core action flow is executed, performing the desired operation on the filtered records using the provided input.
6.  **Results:** The framework displays the results of the bulk action, including any errors or successes, on a results screen.

**Getting Started**

1.  **Install the Package:** Install the Bulk Actions Framework package in your Salesforce org.
2.  **Configure Custom Metadata:** Create a custom metadata record to define the configuration for your bulk action, including the flows to be used and the fields to display on the preview screen.
3.  **Create List View Button:** Add a list view button to the relevant object's list view layout and configure it to invoke the bulk action initializer flow.
4.  **Develop Flows:** Create the necessary evaluation, input, and action flows to implement the logic for your bulk action.

**Example**

Let's say you want to create a bulk action to close a set of selected cases.

1.  **Configure Custom Metadata:**
    - Create a Bulk Action Config record with the appropriate label, API name, and flow API names.
    - Specify the fields to display on the preview screen (e.g., Case Number, Subject, Status).
2.  **Create List View Button:**
    - Add a button to the Case list view layout and configure it to invoke the Bulk Action Initializer Flow with the custom metadata record's developer name.
3.  **Develop Flows:**
    - **Evaluation Flow (Optional):** Create a flow to check if the case is already closed.
    - **Input Flow (Optional):** Not needed for this example.
    - **Action Flow:** Create a flow to update the Case status to "Closed."

**Additional Considerations**

- **Error Handling:** The framework provides error handling mechanisms to display row-by-row error messages for failed actions.
- **Metadata Validation:** Unit tests are included to validate the custom metadata configuration and ensure flow API names are valid.
- **Security:** The framework follows Salesforce security best practices to prevent vulnerabilities like SQL injection and XSS attacks.

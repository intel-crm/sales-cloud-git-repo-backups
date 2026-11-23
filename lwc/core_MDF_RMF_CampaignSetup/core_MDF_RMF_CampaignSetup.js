import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import executeFullContractFlow from "@salesforce/apex/MCPContractController.executeFullContractFlow";
import getAuthenticationUrl from "@salesforce/apex/MCPContractController.getAuthenticationUrl";

const COMPONENT_NAME = "core_MDF_RMF_CampaignSetup";
const PENDING_CONTRACT_FETCH_KEY =
  "core_MDF_RMF_CampaignSetup.pendingContractFetch";
const DEFAULT_ORDER_NUMBER = 1;
const CONTRACT_NOT_FOUND_MESSAGE =
  "No contract was found for the entered Contract Id.";
const INVALID_CONTRACT_ID_MESSAGE = "Enter a numeric Contract Id.";

export default class Core_MDF_RMF_CampaignSetup extends LightningElement {
  // Budget type options supplied by the parent campaign create component
  @api budgetTypeOptions = [];

  // Selected budget type; 'RSA MD' requires a Contract Id
  selectedBudgetType = "";
  // Contract Id entered by the user, used as the MCP contract_number
  contractId = "";
  // Inline error shown below the form
  errorMessage = "";
  // True while the MCP contract lookup is in progress
  isLoading = false;
  // True when the user needs to authenticate before contract data can be fetched
  requiresAuthentication = false;
  // True after the user returns from authentication and can continue the flow
  authenticationCompleted = false;

  // ─── Lifecycle: restore the user input after a separate authentication tab closes ───
  connectedCallback() {
    const pendingFetch = this.consumePendingContractFetch();
    if (pendingFetch) {
      this.selectedBudgetType = pendingFetch.budgetType;
      this.contractId = pendingFetch.contractId;
      this.requiresAuthentication = false;
      this.authenticationCompleted = true;
    }
  }

  get showContractId() {
    return this.selectedBudgetType === "RSA MD";
  }

  get isContinueDisabled() {
    return this.isLoading;
  }

  get actionButtonLabel() {
    return this.requiresAuthentication ? "Authenticate" : "Continue";
  }

  get authenticationMessage() {
    if (this.requiresAuthentication) {
      return "Please authenticate to continue.";
    }
    if (this.authenticationCompleted) {
      return "Authentication completed. Click Continue to proceed.";
    }
    return "";
  }

  // ─── Input handlers ───
  handleBudgetTypeChange(event) {
    this.selectedBudgetType = event.detail.value;
    this.contractId = "";
    this.errorMessage = "";
    this.requiresAuthentication = false;
    this.authenticationCompleted = false;
    this.clearContractIdValidity();
  }

  handleContractIdChange(event) {
    this.contractId = event.detail.value.trim();
    this.errorMessage = "";
    this.clearContractIdValidity();
  }

  async handlePrimaryAction() {
    if (this.requiresAuthentication) {
      await this.handleAuthenticate();
      return;
    }
    await this.handleContinue();
  }

  // ─── Continue: validate inputs, then fetch contract data from the MCP server ───
  async handleContinue() {
    if (this.isLoading) {
      return;
    }
    if (!this.selectedBudgetType) {
      this.errorMessage = "Select a Budget Type to continue.";
      return;
    }

    if (!this.showContractId) {
      this.dispatchSetupComplete(undefined);
      return;
    }

    const contractInput = this.template.querySelector(
      '[data-id="contract-id"]'
    );
    if (!contractInput.reportValidity()) {
      return;
    }
    if (!this.parseContractNumber()) {
      this.setContractIdError(INVALID_CONTRACT_ID_MESSAGE);
      return;
    }

    await this.fetchContractAndContinue();
  }

  // ─── MCP full flow: initialize session + call contract metadata tool ───
  async fetchContractAndContinue() {
    const contractNumber = this.parseContractNumber();
    if (!contractNumber) {
      this.setContractIdError(INVALID_CONTRACT_ID_MESSAGE);
      return;
    }

    this.isLoading = true;
    this.errorMessage = "";
    try {
      const result = await executeFullContractFlow({
        contractNumber,
        orderNumber: DEFAULT_ORDER_NUMBER
      });

      if (!result) {
        this.handleError(
          "fetchContractAndContinue",
          null,
          "No response was returned from the contract service."
        );
        return;
      }

      if (result.requiresAuth === true) {
        this.requiresAuthentication = true;
        this.authenticationCompleted = false;
        return;
      }

      if (!result.success) {
        this.handleError(
          "fetchContractAndContinue",
          result,
          result.error || "Unable to retrieve contract data."
        );
        return;
      }

      const contractData = this.extractContractData(result.body);
      if (!contractData || !contractData.campaign_attributes) {
        this.setContractIdError(CONTRACT_NOT_FOUND_MESSAGE);
        return;
      }

      this.requiresAuthentication = false;
      this.authenticationCompleted = false;
      this.dispatchSetupComplete(contractData);
    } catch (error) {
      this.handleError(
        "fetchContractAndContinue",
        error,
        error?.body?.message || error?.message
      );
    } finally {
      this.isLoading = false;
    }
  }

  async handleAuthenticate() {
    if (!this.parseContractNumber()) {
      this.setContractIdError(INVALID_CONTRACT_ID_MESSAGE);
      return;
    }
    if (!this.savePendingContractFetch()) {
      this.handleError(
        "handleAuthenticate",
        null,
        "Unable to keep your progress. Please try again."
      );
      return;
    }
    await this.redirectToAuthentication();
  }

  // ─── MCP response parsing (JSON or SSE body → content[0].text → contract JSON) ───
  extractContractData(responseBody) {
    const rpcResponse = this.parseRpcResponse(responseBody);
    if (!rpcResponse) {
      return null;
    }
    if (rpcResponse.error) {
      throw new Error(
        rpcResponse.error.message || "The contract service returned an error."
      );
    }

    const toolResult = rpcResponse.result;
    if (!toolResult) {
      return null;
    }

    const textContent = Array.isArray(toolResult.content)
      ? toolResult.content.find(
          (item) => item && item.type === "text" && item.text
        )
      : null;
    if (toolResult.isError === true) {
      throw new Error(
        textContent?.text || "The contract service returned an error."
      );
    }

    let contract = toolResult.structuredContent;
    if (!contract && textContent) {
      contract = this.parseJson(textContent.text);
    }
    if (Array.isArray(contract)) {
      contract = contract.length > 0 ? contract[0] : null;
    }
    if (!contract || typeof contract !== "object") {
      return null;
    }

    // The tool may return campaign_attributes at the top level or nested under contract_metadatavalues.
    if (contract.campaign_attributes) {
      return contract;
    }
    const metadataValues = contract.contract_metadatavalues;
    return metadataValues?.campaign_attributes ? metadataValues : null;
  }

  // Streamable HTTP MCP servers may answer with plain JSON or an SSE stream of "data:" lines.
  parseRpcResponse(responseBody) {
    if (!responseBody) {
      return null;
    }
    if (typeof responseBody === "object") {
      return responseBody;
    }
    const trimmedBody = String(responseBody).trim();
    if (trimmedBody.startsWith("{")) {
      return this.parseJson(trimmedBody);
    }

    let rpcResponse = null;
    trimmedBody
      .split(/\r?\n/)
      .filter((line) => line.startsWith("data:"))
      .forEach((line) => {
        const message = this.parseJson(line.substring("data:".length).trim());
        if (message && (message.result || message.error)) {
          rpcResponse = message;
        }
      });
    return rpcResponse;
  }

  parseJson(value) {
    try {
      return JSON.parse(value);
    } catch {
      return null;
    }
  }

  parseContractNumber() {
    if (!/^\d+$/.test(this.contractId || "")) {
      return null;
    }
    const contractNumber = parseInt(this.contractId, 10);
    return Number.isSafeInteger(contractNumber) && contractNumber > 0
      ? contractNumber
      : null;
  }

  // ─── Authentication redirect (mirrors mcpContractComponent) ───
  async redirectToAuthentication() {
    try {
      const returnPath =
        window.location.pathname +
        window.location.search +
        window.location.hash;
      const authenticationUrl = await getAuthenticationUrl({ returnPath });
      if (!authenticationUrl) {
        this.clearPendingContractFetch();
        this.handleError(
          "redirectToAuthentication",
          null,
          "Unable to start authentication."
        );
        return;
      }
      window.location.assign(authenticationUrl);
    } catch (error) {
      this.clearPendingContractFetch();
      this.handleError(
        "redirectToAuthentication",
        error,
        error?.body?.message || error?.message
      );
    }
  }

  savePendingContractFetch() {
    try {
      window.sessionStorage.setItem(
        PENDING_CONTRACT_FETCH_KEY,
        JSON.stringify({
          budgetType: this.selectedBudgetType,
          contractId: this.contractId
        })
      );
      return true;
    } catch {
      return false;
    }
  }

  clearPendingContractFetch() {
    try {
      window.sessionStorage.removeItem(PENDING_CONTRACT_FETCH_KEY);
    } catch {
      // Storage unavailable; nothing to clear.
    }
  }

  // Removed on load so the user can return to this page and explicitly continue the flow.
  consumePendingContractFetch() {
    let stored;
    try {
      stored = window.sessionStorage.getItem(PENDING_CONTRACT_FETCH_KEY);
    } catch {
      return null;
    }
    if (!stored) {
      return null;
    }
    this.clearPendingContractFetch();

    const parsed = this.parseJson(stored);
    const contractId =
      typeof parsed?.contractId === "string" ? parsed.contractId.trim() : "";
    if (!parsed?.budgetType || !/^\d+$/.test(contractId)) {
      return null;
    }
    return { budgetType: parsed.budgetType, contractId };
  }

  // ─── Notify parent that setup is complete ───
  dispatchSetupComplete(contractData) {
    this.dispatchEvent(
      new CustomEvent("rmfsetupcomplete", {
        bubbles: true,
        composed: true,
        detail: {
          budgetType: this.selectedBudgetType,
          contractId: this.contractId,
          contractData,
          campaignAttributes: contractData?.campaign_attributes
        }
      })
    );
  }

  // ─── Error handling ───
  handleError(methodName, error, message) {
    console.error(`${COMPONENT_NAME}.${methodName}:`, error);
    this.errorMessage =
      message || "An unexpected error occurred while retrieving contract data.";
    this.showToast("Error", this.errorMessage, "error");
  }

  setContractIdError(message) {
    this.errorMessage = message;
    const contractInput = this.template.querySelector(
      '[data-id="contract-id"]'
    );
    if (contractInput) {
      contractInput.setCustomValidity(message);
      contractInput.reportValidity();
    }
  }

  clearContractIdValidity() {
    const contractInput = this.template.querySelector(
      '[data-id="contract-id"]'
    );
    if (contractInput) {
      contractInput.setCustomValidity("");
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
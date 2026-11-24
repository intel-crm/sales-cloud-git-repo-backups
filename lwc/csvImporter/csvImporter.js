import { LightningElement, api, track } from 'lwc';
import parseFile from
    '@salesforce/apex/ExcelImportParser.parseFile';
import processRecords from
    '@salesforce/apex/AccountExactMatchProcessor.processRecords';

export default class CsvImporter extends LightningElement {

    @api recordId = '';

    // ─── Step Control ────────────────────────
    currentStep  = '1';
    isLoading    = false;
    errorMessage = '';

    // ─── Step 1 ──────────────────────────────
    isUploaded = false;
    fileName   = '';

    // ─── Parser Output ───────────────────────
    detectedColumnsJson = '[]';
    parsedDataJson      = '';
    totalRows           = 0;

    // ─── Step 2 ──────────────────────────────
    companyNameValue = '';
    productValue     = '';
    mappingError     = '';
    _columnOptions   = [];

    // ─── Step 3 ──────────────────────────────
    tasksCreated       = 0;
    notFoundCount      = 0;
    notFoundListString = '';

    // ─── Step Getters ────────────────────────
    get isStep1() {
        return this.currentStep === '1' &&
               !this.isLoading;
    }
    get isStep2() {
        return this.currentStep === '2' &&
               !this.isLoading;
    }
    get isStep3() {
        return this.currentStep === '3' &&
               !this.isLoading;
    }
    get hasUnmatched() {
        return this.notFoundCount > 0;
    }
    get allMatched() {
        return this.notFoundCount === 0;
    }
    get loadingMessage() {
        if (this.currentStep === '1')
            return 'Parsing your file...';
        if (this.currentStep === '2')
            return 'Processing records...';
        return 'Please wait...';
    }

    // ─── Column Options ──────────────────────
    get columnOptions() {
        return this._columnOptions.length
            ? this._columnOptions
            : [{ label: '-- Select Column --', value: '' }];
    }

    buildColumnOptions(json) {
        try {
            const cols = JSON.parse(json || '[]');
            return [
                { label: '-- Select Column --', value: '' },
                ...cols.map(col => ({
                    label: col,
                    value: col
                }))
            ];
        } catch (e) {
            return [{ label: '-- Select Column --', value: '' }];
        }
    }

    // ─── Step 1: Upload ──────────────────────
    async handleUploadFinished(event) {
        const files = event.detail.files;

        if (!files || files.length === 0) {
            this.errorMessage =
                'No file detected. ' +
                'Please try again.';
            return;
        }

        const file             = files[0];
        const contentVersionId = file.contentVersionId;

        if (!contentVersionId) {
            this.errorMessage =
                'File ID not found. ' +
                'Please try again.';
            return;
        }

        // ── Validate file extension ──────────
        const ext = file.name
            .split('.')
            .pop()
            .toLowerCase();

        if (ext !== 'csv') {
            this.errorMessage =
                `Invalid file type: .${ext}. ` +
                'Please upload a CSV file.';
            return;
        }

        this.fileName     = file.name;
        this.isUploaded   = true;
        this.isLoading    = true;
        this.errorMessage = '';

        try {
            const results = await parseFile({
                contentVersionId: contentVersionId
            });

            if (!results || results.length === 0) {
                this.errorMessage =
                    'No response from parser.';
                this.isUploaded = false;
                this.fileName   = '';
                return;
            }

            const result = results[0];

            if (!result.isSuccess) {
                this.errorMessage =
                    result.errorMessage;
                this.isUploaded = false;
                this.fileName   = '';
                return;
            }

            this.detectedColumnsJson =
                result.detectedColumnsJson || '[]';
            this.parsedDataJson =
                result.parsedDataJson || '[]';
            this.totalRows =
                result.totalRows || 0;

            // ── Build column options once ────
            this._columnOptions =
                this.buildColumnOptions(
                    result.detectedColumnsJson
                );

            if (result.autoMappingJson) {
                this.applyAutoMapping(
                    result.autoMappingJson
                );
            }

            if (result.columnsAlreadyMatch) {
                await this.runProcessRecords(
                    result.autoMappingJson
                );
            } else {
                this.currentStep = '2';
            }

        } catch (e) {
            console.error('Upload error:', e);
            this.errorMessage =
                e.body?.message ||
                e.message ||
                'Unknown error occurred';
            this.isUploaded = false;
            this.fileName   = '';
        } finally {
            this.isLoading = false;
        }
    }

    // ─── Apply Auto Mapping ──────────────────
    applyAutoMapping(autoMappingJson) {
        try {
            const autoMap =
                JSON.parse(autoMappingJson);
            if (autoMap.company_name) {
                this.companyNameValue =
                    autoMap.company_name;
            }
            if (autoMap.product) {
                this.productValue =
                    autoMap.product;
            }
        } catch (e) {
            console.error(
                'Auto mapping parse error:', e
            );
        }
    }

    // ─── Step 2: Change ──────────────────────
    handleMappingChange(event) {
        const name  = event.target.name;
        const value = event.detail.value;

        if (name === 'company_name') {
            this.companyNameValue = value;
        }
        if (name === 'product') {
            this.productValue = value;
        }
        this.mappingError = '';
    }

    // ─── Step 2: Confirm ─────────────────────
    async handleConfirmMapping() {
        if (!this.companyNameValue) {
            this.mappingError =
                'Please select the ' +
                'Company Name column.';
            return;
        }
        if (!this.productValue) {
            this.mappingError =
                'Please select the ' +
                'Product column.';
            return;
        }

        const mapping = {
            company_name: this.companyNameValue,
            product:      this.productValue
        };

        this.isLoading    = true;
        this.errorMessage = '';

        try {
            await this.runProcessRecords(
                JSON.stringify(mapping)
            );
        } catch (e) {
            this.errorMessage =
                e.body?.message ||
                e.message ||
                'Unknown error occurred';
        } finally {
            this.isLoading = false;
        }
    }

    // ─── Run Process Records ─────────────────
    async runProcessRecords(columnMappingJson) {
        const results = await processRecords({
            parsedDataJson:    this.parsedDataJson,
            columnMappingJson: columnMappingJson
        });

        if (!results || results.length === 0) {
            throw new Error(
                'No response from processor.'
            );
        }

        const result = results[0];

        if (!result.isSuccess) {
            throw new Error(result.errorMessage);
        }

        this.tasksCreated =
            result.tasksCreated || 0;
        this.notFoundCount =
            result.notFoundCount || 0;
        this.notFoundListString =
            result.notFoundListString || '';
        this.currentStep = '3';
    }

    // ─── Restart ─────────────────────────────
    handleRestart() {
        this.currentStep         = '1';
        this.isLoading           = false;
        this.errorMessage        = '';
        this.isUploaded          = false;
        this.fileName            = '';
        this.detectedColumnsJson = '[]';
        this.parsedDataJson      = '';
        this.totalRows           = 0;
        this.companyNameValue    = '';
        this.productValue        = '';
        this.mappingError        = '';
        this.tasksCreated        = 0;
        this.notFoundCount       = 0;
        this.notFoundListString  = '';
        this._columnOptions      = [];
    }
}
/**
 * @description LWC File Upload - Fixed all spinner/loader issues
 * @component   core_MDF_fileUploadComponent
 * @author      Core MDF Team
 * @created     2026
 */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent }                      from 'lightning/platformShowToastEvent';
import { refreshApex }                         from '@salesforce/apex';

// Apex Methods
import uploadFileBlob        from '@salesforce/apex/Core_MDF_FileUploadController.uploadFileBlob';
import uploadFileChunk       from '@salesforce/apex/Core_MDF_FileUploadController.uploadFileChunk';
import checkAssemblyStatus   from '@salesforce/apex/Core_MDF_FileUploadController.checkAssemblyStatus';
import getLinkedFiles        from '@salesforce/apex/Core_MDF_FileUploadController.getLinkedFiles';
import deleteUploadedFile    from '@salesforce/apex/Core_MDF_FileUploadController.deleteUploadedFile';
import cleanupOrphanedChunks from '@salesforce/apex/Core_MDF_FileUploadController.cleanupOrphanedChunks';

// ── Constants ──────────────────────────────────────────────────────────────────
const SMALL_FILE_LIMIT  = 3 * 1024 * 1024;
const CHUNK_SIZE        = 750 * 1024;
const MAX_FILE_SIZE     = 2 * 1024 * 1024 * 1024;
const POLL_INTERVAL_MS  = 3000;
const MAX_POLL_ATTEMPTS = 100;

// ── Table Columns ──────────────────────────────────────────────────────────────
const TABLE_COLUMNS = [
    {
        label    : 'File Name',
        fieldName: 'title',
        type     : 'text',
        sortable : true
    },
    {
        label       : 'Type',
        fieldName   : 'fileType',
        type        : 'text',
        initialWidth: 80
    },
    {
        label       : 'Size',
        fieldName   : 'fileSizeFormatted',
        type        : 'text',
        initialWidth: 100
    },
    {
        label    : 'Uploaded On',
        fieldName: 'createdDate',
        type     : 'date',
        typeAttributes: {
            year  : 'numeric',
            month : 'short',
            day   : '2-digit',
            hour  : '2-digit',
            minute: '2-digit'
        }
    },
    {
        type          : 'action',
        typeAttributes: {
            rowActions: [
                { label: '⬇️ Download', name: 'download' },
                { label: '🗑️ Delete',   name: 'delete'   }
            ]
        }
    }
];

export default class Core_MDF_FileUploadComponent extends LightningElement {

    // ── Public ─────────────────────────────────────────────────────────────────
    @api recordId;

    // ── Tracked ────────────────────────────────────────────────────────────────
    @track selectedFile       = null;
    @track isUploading        = false;
    @track uploadProgress     = 0;
    @track statusMessage      = '';
    @track statusType         = '';
    @track uploadedFiles      = [];
    @track isLoadingFiles     = false;  // ✅ Default false
    @track chunkStatusMessage = '';
    @track progressLabel      = '';
    @track totalChunks        = 0;

    // ── Private ────────────────────────────────────────────────────────────────
    _isCancelled            = false;
    _uploadId               = null;
    _jobId                  = null;
    _pollTimer              = null;
    _pollAttempts           = 0;
    _wiredFilesResult       = null;
    _uploadFileName         = '';
    _uploadFileSize         = 0;
    _uploadFileTotalChunks  = 0;
    _lastContentDocumentId  = null;
    tableColumns            = TABLE_COLUMNS;

    // ── Wire ───────────────────────────────────────────────────────────────────
    @wire(getLinkedFiles, { recordId: '$recordId' })
    wiredFiles(result) {
        this._wiredFilesResult = result;

        // ✅ Always set isLoadingFiles false when wire responds
        this.isLoadingFiles = false;

        if (result.data) {
            this.uploadedFiles = result.data;
        } else if (result.error) {
            // ✅ Set empty array on error so spinner stops
            this.uploadedFiles = [];
            console.error('getLinkedFiles error:', result.error);
        }
    }

    // ── Getters ────────────────────────────────────────────────────────────────
    get isUploadDisabled() {
        return !this.selectedFile || this.isUploading;
    }

    get hasFiles() {
        return this.uploadedFiles && this.uploadedFiles.length > 0;
    }

    get fileCount() {
        return this.uploadedFiles ? this.uploadedFiles.length : 0;
    }

    get fileSizeFormatted() {
        if (!this.selectedFile || !this.selectedFile.size) return '';
        return this._formatBytes(this.selectedFile.size);
    }

    get statusBoxClass() {
        const base = 'slds-box slds-m-top_small slds-p-around_small ';
        const map  = {
            success : 'slds-theme_success',
            error   : 'slds-theme_error',
            info    : 'slds-theme_info',
            warning : 'slds-theme_warning'
        };
        return base + (map[this.statusType] || 'slds-theme_info');
    }

    get statusIcon() {
        const map = {
            success : 'utility:success',
            error   : 'utility:error',
            info    : 'utility:info',
            warning : 'utility:warning'
        };
        return map[this.statusType] || 'utility:info';
    }

    // ── Lifecycle ──────────────────────────────────────────────────────────────
    disconnectedCallback() {
        this._clearPollTimer();
    }

    // ── Event Handlers ─────────────────────────────────────────────────────────

    handleFileChange(event) {
        const files = event.target.files;
        if (!files || files.length === 0) return;

        const file = files[0];
        if (!file) return;

        if (file.size > MAX_FILE_SIZE) {
            this._setStatus(
                `File exceeds 2GB limit. `
                + `Size: ${this._formatBytes(file.size)}`,
                'error'
            );
            this.selectedFile  = null;
            event.target.value = '';
            return;
        }

        this.selectedFile       = file;
        this.totalChunks        = Math.ceil(file.size / CHUNK_SIZE);
        this.statusMessage      = '';
        this.uploadProgress     = 0;
        this.chunkStatusMessage = '';

        this._setStatus(
            `Selected: ${file.name} | `
            + `${this._formatBytes(file.size)} | `
            + `${this.totalChunks} chunk(s)`,
            'info'
        );
    }

    /**
     * ✅ Fixed handleUpload - proper try/catch/finally
     */
    async handleUpload() {
        if (!this.selectedFile
            || !this.selectedFile.size
            || !this.selectedFile.name
            || this.isUploading
        ) {
            return;
        }

        // Capture file info before async ops
        this._uploadFileName        = this.selectedFile.name;
        this._uploadFileSize        = this.selectedFile.size;
        this._uploadFileTotalChunks = Math.ceil(
            this.selectedFile.size / CHUNK_SIZE
        );
        this._lastContentDocumentId = null;

        // Set uploading state
        this.isUploading    = true;
        this._isCancelled   = false;
        this.uploadProgress = 0;
        this._uploadId      = this._generateUploadId();
        this._jobId         = null;

        let uploadSuccess = false;

        try {
            if (this._uploadFileSize <= SMALL_FILE_LIMIT) {
                await this._uploadSmallFile();
            } else {
                await this._uploadLargeFile();
            }

            if (!this._isCancelled) {
                uploadSuccess = true;
            }

        } catch (error) {
            if (!this._isCancelled) {
                const msg = error?.body?.message
                          || error?.message
                          || 'Upload failed. Please try again.';
                this._setStatus(msg, 'error');
                this.showToast('Upload Failed', msg, 'error');

                if (this._uploadId) {
                    await this._cleanup(this._uploadId);
                }
            }
        } finally {
            // ✅ ALWAYS runs - stops upload spinner
            this.isUploading        = false;
            this.chunkStatusMessage = '';
            this.progressLabel      = '';

            if (uploadSuccess) {
                this._handleUploadSuccess();
            }
        }
    }

    async handleCancel() {
        this._isCancelled = true;
        this._clearPollTimer();
        this.isUploading        = false;
        this.chunkStatusMessage = '';
        this.progressLabel      = '';
        this.uploadProgress     = 0;
        this._setStatus('Upload cancelled', 'warning');
        this.showToast('Cancelled', 'Upload cancelled', 'warning');

        if (this._uploadId) {
            await this._cleanup(this._uploadId);
        }
    }

    handleClear() {
        this._clearFileSelection();
        this.statusMessage = '';
    }

    /**
     * ✅ Fixed handleRefresh - with timeout fallback
     */
    handleRefresh() {
        // ✅ Only show spinner if recordId exists
        if (this.recordId) {
            this.isLoadingFiles = true;
            refreshApex(this._wiredFilesResult);

            // ✅ Safety timeout - stop spinner after 10s max
            setTimeout(() => {
                this.isLoadingFiles = false;
            }, 10000);
        }
    }

    async handleRowAction(event) {
        const action = event.detail.action.name;
        const row    = event.detail.row;
        if (action === 'download') {
            window.open(row.downloadUrl, '_blank');
        } else if (action === 'delete') {
            await this._deleteFile(row);
        }
    }

    // ── Private Upload Methods ─────────────────────────────────────────────────

    async _uploadSmallFile() {
        this.progressLabel      = 'Reading file...';
        this.chunkStatusMessage = '📖 Reading file data...';
        this._setStatus('Preparing file...', 'info');

        if (!this.selectedFile) {
            throw new Error('File reference lost. Please re-select file.');
        }

        const base64Data = await this._readFileAsBase64(this.selectedFile);

        if (this._isCancelled) return;

        this.uploadProgress     = 30;
        this.progressLabel      = 'Uploading...';
        this.chunkStatusMessage = '📤 Uploading to Salesforce...';
        this._setStatus('Uploading file...', 'info');

        const contentDocumentId = await uploadFileBlob({
            fileName   : this._uploadFileName,
            base64Data : base64Data,
            recordId   : this.recordId || ''
        });

        if (this._isCancelled) return;

        this._lastContentDocumentId = contentDocumentId;
        this.uploadProgress         = 100;
    }

    async _uploadLargeFile() {
        const file        = this.selectedFile;
        const totalChunks = this._uploadFileTotalChunks;

        if (!file || !file.size) {
            throw new Error('File reference lost. Please re-select file.');
        }

        for (let i = 0; i < totalChunks; i++) {
            if (this._isCancelled) return;

            const start       = i * CHUNK_SIZE;
            const end         = Math.min(start + CHUNK_SIZE, file.size);
            const chunkNum    = i + 1;
            const isLastChunk = i === totalChunks - 1;
            const chunkBlob   = file.slice(start, end);

            this.uploadProgress     = Math.round(
                (chunkNum / totalChunks) * 85
            );
            this.progressLabel      =
                `Uploading chunk ${chunkNum}/${totalChunks}`;
            this.chunkStatusMessage =
                `📤 Chunk ${chunkNum}/${totalChunks} | `
                + `${this._formatBytes(end - start)} | `
                + `${this._formatBytes(end)} / `
                + `${this._formatBytes(file.size)}`;

            const base64Chunk = await this._readFileAsBase64(chunkBlob);

            if (this._isCancelled) return;

            const result = await uploadFileChunk({
                fileName    : this._uploadFileName,
                base64Chunk : base64Chunk,
                chunkIndex  : i,
                totalChunks : totalChunks,
                recordId    : this.recordId || '',
                uploadId    : this._uploadId
            });

            if (isLastChunk && result && result.jobId) {
                this._jobId = result.jobId;
            }
        }

        if (this._isCancelled) return;

        if (this._jobId) {
            await this._pollAssemblyStatus();
        }
    }

    _pollAssemblyStatus() {
        this._pollAttempts      = 0;
        this.progressLabel      = 'Assembling file...';
        this.uploadProgress     = 90;
        this.chunkStatusMessage = '⚙️ Assembling file on server...';
        this._setStatus('Assembling file chunks...', 'info');

        return new Promise((resolve, reject) => {
            this._pollTimer = setInterval(async () => {
                try {
                    if (this._isCancelled) {
                        this._clearPollTimer();
                        resolve();
                        return;
                    }

                    this._pollAttempts++;

                    const status = await checkAssemblyStatus({
                        jobId    : this._jobId,
                        uploadId : this._uploadId
                    });

                    this.uploadProgress = Math.min(
                        90 + this._pollAttempts, 99
                    );
                    this.chunkStatusMessage =
                        `⚙️ Assembling... `
                        + `(${this._pollAttempts * 3}s elapsed)`;

                    if (status.isComplete) {
                        this._clearPollTimer();
                        this.uploadProgress         = 100;
                        this._lastContentDocumentId = status.contentDocumentId;
                        resolve();

                    } else if (status.isFailed) {
                        this._clearPollTimer();
                        reject(new Error(
                            status.errorMessage || 'File assembly failed'
                        ));

                    } else if (this._pollAttempts >= MAX_POLL_ATTEMPTS) {
                        this._clearPollTimer();
                        reject(new Error('Assembly timeout.'));
                    }

                } catch (pollError) {
                    this._clearPollTimer();
                    reject(pollError);
                }

            }, POLL_INTERVAL_MS);
        });
    }

    /**
     * ✅ Fixed _handleUploadSuccess
     *    Called from finally AFTER isUploading = false
     *    Does NOT set isLoadingFiles if no recordId
     */
    _handleUploadSuccess() {
        const fileName          = this._uploadFileName         || 'File';
        const contentDocumentId = this._lastContentDocumentId  || '';

        // ✅ Status message with ContentDocumentId
        this._setStatus(
            `✅ "${fileName}" uploaded successfully! `
            + `| Document ID: ${contentDocumentId}`,
            'success'
        );

        // ✅ Toast with ContentDocumentId
        this.showToast(
            'Upload Successful',
            `"${fileName}" uploaded successfully! `
            + `Document ID: ${contentDocumentId}`,
            'success'
        );

        // Clear file selection
        this._clearFileSelection();

        // Reset tracking vars
        this._uploadId              = null;
        this._jobId                 = null;
        this._pollAttempts          = 0;
        this._uploadFileName        = '';
        this._uploadFileSize        = 0;
        this._uploadFileTotalChunks = 0;
        this._lastContentDocumentId = null;

        // Refresh file list
        if (this.recordId) {
            this.isLoadingFiles = true;
            refreshApex(this._wiredFilesResult);

            setTimeout(() => {
                this.isLoadingFiles = false;
            }, 10000);
        }
    }

    // ── Private Utility Methods ────────────────────────────────────────────────

    _clearFileSelection() {
        this.selectedFile       = null;
        this.uploadProgress     = 0;
        this.totalChunks        = 0;
        this.chunkStatusMessage = '';
        this.progressLabel      = '';
        const input = this.template.querySelector('[data-id="fileInput"]');
        if (input) input.value = '';
    }

    _readFileAsBase64(fileOrBlob) {
        return new Promise((resolve, reject) => {
            if (!fileOrBlob) {
                reject(new Error('No file data to read'));
                return;
            }
            const reader   = new FileReader();
            reader.onload  = () => {
                if (!reader.result) {
                    reject(new Error('FileReader returned empty result'));
                    return;
                }
                const parts  = reader.result.split(',');
                const base64 = parts.length > 1 ? parts[1] : parts[0];
                resolve(base64);
            };
            reader.onerror = () => reject(
                new Error('Failed to read file: ' + reader.error?.message)
            );
            reader.readAsDataURL(fileOrBlob);
        });
    }

    async _deleteFile(row) {
        // eslint-disable-next-line no-alert
        if (!confirm(`Delete "${row.title}"?`)) return;
        try {
            await deleteUploadedFile({
                contentDocumentId: row.contentDocumentId
            });
            this.showToast(
                'Deleted',
                `"${row.title}" deleted successfully`,
                'success'
            );
            refreshApex(this._wiredFilesResult);
        } catch (error) {
            this.showToast(
                'Error',
                error?.body?.message || 'Delete failed',
                'error'
            );
        }
    }

    async _cleanup(uploadId) {
        try {
            if (uploadId) {
                await cleanupOrphanedChunks({ uploadId });
            }
        } catch (e) {
            console.error('Cleanup error:', e);
        }
    }

    _generateUploadId() {
        return 'MDF_'
            + Date.now()
            + '_'
            + Math.random().toString(36).substring(2, 10);
    }

    _formatBytes(bytes) {
        if (bytes === null
            || bytes === undefined
            || bytes === 0) return '0 B';
        if (bytes < 1024)       return `${bytes} B`;
        if (bytes < 1048576)    return `${(bytes / 1024).toFixed(2)} KB`;
        if (bytes < 1073741824) return `${(bytes / 1048576).toFixed(2)} MB`;
        return `${(bytes / 1073741824).toFixed(2)} GB`;
    }

    _setStatus(message, type) {
        this.statusMessage = message;
        this.statusType    = type;
    }

    _clearPollTimer() {
        if (this._pollTimer) {
            clearInterval(this._pollTimer);
            this._pollTimer = null;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
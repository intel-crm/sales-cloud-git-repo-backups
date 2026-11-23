import { LightningElement, api, track } from 'lwc';
import uploadFile from '@salesforce/apex/Core_MDF_FileUploadAPIController.uploadFile';

// ✅ Updated limits
const MAX_FILE_SIZE  = 2 * 1024 * 1024 * 1024; // 2GB
const CHUNK_SIZE     = 4 * 1024 * 1024;          // 4MB per chunk (Apex heap safe)

export default class Core_MDF_fileUploadViaAPI extends LightningElement {

    @api recordId;
    @api acceptedFormats = '.pdf,.png,.jpg,.jpeg,.doc,.docx,.xlsx,.csv';
    @api allowMultiple   = false;
    @api uploadLabel     = 'Upload Files';

    @track isUploading    = false;
    @track uploadProgress = 0;
    @track uploadedFiles  = [];
    @track errorMessage   = '';
    @track successMessage = '';
    @track showError      = false;
    @track showSuccess    = false;
    @track currentFileName = '';
    @track uploadedSize    = '';
    @track totalSize       = '';

    // ================================================================
    // FILE SELECTION HANDLER
    // ================================================================

    handleFileChange(event) {
        this.resetMessages();
        const files = [...event.target.files];
        if (!files || files.length === 0) return;
        this.validateAndUpload(files);
    }

    handleDrop(event) {
        event.preventDefault();
        event.currentTarget.classList.remove('drag-over');
        this.resetMessages();
        const files = [...event.dataTransfer.files];
        if (files.length > 0) this.validateAndUpload(files);
    }

    validateAndUpload(files) {
        // ✅ Check max file size 2GB
        const oversizedFiles = files.filter(f => f.size > MAX_FILE_SIZE);
        if (oversizedFiles.length > 0) {
            this.showErrorMessage(
                `File(s) exceed max size of 2GB: ${oversizedFiles.map(f => f.name).join(', ')}`
            );
            return;
        }
        this.processFiles(files);
    }

    // ================================================================
    // PROCESS FILES
    // ================================================================

    async processFiles(files) {
        this.isUploading    = true;
        this.uploadProgress = 0;
        this.uploadedFiles  = [];

        try {
            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                this.currentFileName = file.name;
                this.totalSize       = this.formatFileSize(file.size);

                console.log(`📤 Processing file ${i + 1}/${files.length}: ${file.name}`);
                console.log(`📤 File size: ${this.formatFileSize(file.size)}`);

                await this.uploadSingleFile(file, i, files.length);
            }

            this.showSuccessMessage(`${files.length} file(s) uploaded successfully!`);
            this.dispatchUploadSuccess();

        } catch (error) {
            console.error('❌ Upload Error:', error);
            const errorMsg = error?.body?.message
                || error?.message
                || 'Upload failed. Please try again.';
            this.showErrorMessage(errorMsg);
        } finally {
            this.isUploading     = false;
            this.currentFileName = '';
        }
    }

    // ================================================================
    // UPLOAD SINGLE FILE WITH CHUNKING IN LWC
    // ================================================================

    async uploadSingleFile(file, fileIndex, totalFiles) {
        return new Promise((resolve, reject) => {

            // ✅ For large files use chunked reading
            if (file.size > CHUNK_SIZE) {
                this.uploadLargeFile(file, fileIndex, totalFiles)
                    .then(resolve)
                    .catch(reject);
            } else {
                this.uploadSmallFile(file, fileIndex, totalFiles)
                    .then(resolve)
                    .catch(reject);
            }
        });
    }

    // ================================================================
    // SMALL FILE UPLOAD (< 4MB) - Single Read
    // ================================================================

    async uploadSmallFile(file, fileIndex, totalFiles) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            reader.onload = async () => {
                try {
                    const base64Data = reader.result.split(',')[1];

                    const uploadResult = await uploadFile({
                        fileName  : file.name,
                        base64Data: base64Data,
                        title     : file.name.substring(0, file.name.lastIndexOf('.')) || file.name,
                        recordId  : this.recordId || ''
                    });

                    console.log('✅ Upload Result:', JSON.stringify(uploadResult));

                    if (uploadResult.success) {
                        // ✅ contentDocumentId now in response
                        this.uploadedFiles = [
                            ...this.uploadedFiles,
                            {
                                id             : uploadResult.contentVersionId,
                                contentDocId   : uploadResult.contentDocumentId, // ✅
                                name           : file.name,
                                size           : this.formatFileSize(file.size)
                            }
                        ];

                        this.uploadProgress = Math.round(
                            ((fileIndex + 1) / totalFiles) * 100
                        );
                        resolve(uploadResult);
                    } else {
                        reject(new Error(uploadResult.message));
                    }
                } catch (error) {
                    reject(error);
                }
            };

            reader.onerror = () => reject(new Error('File reading failed: ' + file.name));
            reader.readAsDataURL(file);
        });
    }

    // ================================================================
    // LARGE FILE UPLOAD (> 4MB) - Chunk by Chunk Reading
    // ================================================================

    async uploadLargeFile(file, fileIndex, totalFiles) {
        let offset      = 0;
        let chunkNumber = 0;
        let uploadResult;

        while (offset < file.size) {
            const chunk     = file.slice(offset, offset + CHUNK_SIZE);
            const base64    = await this.readChunkAsBase64(chunk);
            const base64Data = base64.split(',')[1];

            // ✅ Update progress per chunk
            const chunkProgress = Math.round((offset / file.size) * 100);
            this.uploadProgress = Math.round(
                ((fileIndex / totalFiles) + (chunkProgress / 100 / totalFiles)) * 100
            );
            this.uploadedSize = this.formatFileSize(offset);

            console.log(`📦 Uploading chunk ${chunkNumber + 1} | Offset: ${offset} | Progress: ${chunkProgress}%`);

            uploadResult = await uploadFile({
                fileName  : file.name,
                base64Data: base64Data,
                title     : file.name.substring(0, file.name.lastIndexOf('.')) || file.name,
                recordId  : this.recordId || ''
            });

            if (!uploadResult.success) {
                throw new Error(uploadResult.message);
            }

            offset += CHUNK_SIZE;
            chunkNumber++;
        }

        // ✅ After all chunks done
        if (uploadResult && uploadResult.success) {
            this.uploadedFiles = [
                ...this.uploadedFiles,
                {
                    id          : uploadResult.contentVersionId,
                    contentDocId: uploadResult.contentDocumentId, // ✅
                    name        : file.name,
                    size        : this.formatFileSize(file.size)
                }
            ];

            this.uploadProgress = Math.round(((fileIndex + 1) / totalFiles) * 100);
        }

        return uploadResult;
    }

    // ================================================================
    // READ CHUNK AS BASE64
    // ================================================================

    readChunkAsBase64(chunk) {
        return new Promise((resolve, reject) => {
            const reader  = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.onerror = () => reject(new Error('Chunk reading failed'));
            reader.readAsDataURL(chunk);
        });
    }

    // ================================================================
    // HELPER METHODS
    // ================================================================

    formatFileSize(bytes) {
        if (bytes < 1024)                  return bytes + ' B';
        if (bytes < 1024 * 1024)           return (bytes / 1024).toFixed(1) + ' KB';
        if (bytes < 1024 * 1024 * 1024)   return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + ' GB';
    }

    resetMessages() {
        this.errorMessage   = '';
        this.successMessage = '';
        this.showError      = false;
        this.showSuccess    = false;
    }

    showErrorMessage(msg) {
        this.errorMessage = msg;
        this.showError    = true;
        this.showSuccess  = false;
    }

    showSuccessMessage(msg) {
        this.successMessage = msg;
        this.showSuccess    = true;
        this.showError      = false;
    }

    dispatchUploadSuccess() {
        this.dispatchEvent(
            new CustomEvent('uploadcomplete', {
                detail: { uploadedFiles: this.uploadedFiles }
            })
        );
    }

    handleRemoveFile(event) {
        const fileId = event.currentTarget.dataset.id;
        this.uploadedFiles = this.uploadedFiles.filter(f => f.id !== fileId);
    }

    handleDragOver(event) {
        event.preventDefault();
        event.currentTarget.classList.add('drag-over');
    }

    handleDragLeave(event) {
        event.currentTarget.classList.remove('drag-over');
    }

    // ================================================================
    // GETTERS
    // ================================================================

    get hasUploadedFiles() {
        return this.uploadedFiles.length > 0;
    }

    get progressStyle() {
        return `width: ${this.uploadProgress}%`;
    }

    get progressLabel() {
        if (this.uploadedSize && this.totalSize) {
            return `Uploading ${this.currentFileName} - ${this.uploadedSize} / ${this.totalSize} (${this.uploadProgress}%)`;
        }
        return `Uploading ${this.currentFileName} - ${this.uploadProgress}%`;
    }
    // ✅ Programmatically trigger file input
    handleBrowseClick(event) {
        event.preventDefault();
        const fileInput = this.template.querySelector('[data-id="fileInput"]');
        if (fileInput) {
            fileInput.click();
        }
    }
}
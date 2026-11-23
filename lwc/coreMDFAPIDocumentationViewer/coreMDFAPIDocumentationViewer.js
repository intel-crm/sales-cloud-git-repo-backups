import { LightningElement, wire } from 'lwc';
import getAPIDocumentation from '@salesforce/apex/Core_MDF_APIDocumentationController.getAPIDocumentation';
import getCommunityURL from '@salesforce/apex/Core_MDF_APIDocumentationController.getCommunityURL';

export default class CoreMDFAPIDocumentationViewer extends LightningElement {
    apiRecords = [];
    communityUrl = '';
    isLoading = true;
    errorMessage = '';
    expandedPanel = null;

    @wire(getAPIDocumentation)
    wiredAPIRecords({ error, data }) {
        if (data) {
            this.apiRecords = this.buildApiPanels(data);
            this.isLoading = false;
        } else if (error) {
            this.errorMessage = error.body?.message || 'Failed to load API documentation';
            console.error('Error loading API records:', error);
            this.isLoading = false;
        }
    }

    @wire(getCommunityURL)
    wiredCommunityURL({ error, data }) {
        if (data) {
            this.communityUrl = data;
        } else if (error) {
            console.error('Error loading community URL:', error);
            this.communityUrl = 'https://partnercenter.my.site.com/Partnercenter/API_Documentation';
        }
    }

    handleExpandAll() {
        this.apiRecords = this.apiRecords.map(panel => ({
            ...panel,
            isExpanded: true
        }));
    }

    handleCollapseAll() {
        this.apiRecords = this.apiRecords.map(panel => ({
            ...panel,
            isExpanded: false
        }));
    }

    handleTogglePanel(event) {
        const panelId = event.currentTarget.dataset.panelId;
        this.apiRecords = this.apiRecords.map(panel => {
            if (panel.panelId === panelId) {
                return { ...panel, isExpanded: !panel.isExpanded };
            }
            return panel;
        });
    }

    handleVersionChange(event) {
        const panelId = event.currentTarget.dataset.panelId;
        const selectedVersion = event.detail?.value || event.currentTarget.value;

        this.apiRecords = this.apiRecords.map(panel => {
            if (panel.panelId !== panelId) {
                return panel;
            }

            const selectedRecord = panel.versions.find(version => version.id === selectedVersion) || panel.selectedRecord;
            return this.withSelectedRecord({
                ...panel,
                selectedVersion,
                selectedRecord
            });
        });
    }

    downloadJSON(content, filename) {
        try {
            const element = document.createElement('a');
            const file = new Blob([content], { type: 'application/json' });
            element.href = URL.createObjectURL(file);
            element.download = filename;
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);
        } catch (error) {
            console.error('Error downloading file:', error);
        }
    }

    handleDownloadRequest(event) {
        const record = this.getSelectedRecord(event.currentTarget.dataset.panelId);
        if (!record) {
            return;
        }
        const filename = `${record.operationName.replace(/\s+/g, '-')}-${record.version || 'Version'}-Request.json`;
        this.downloadJSON(record.requestExample, filename);
    }

    handleDownloadResponse(event) {
        const record = this.getSelectedRecord(event.currentTarget.dataset.panelId);
        if (!record) {
            return;
        }
        const filename = `${record.operationName.replace(/\s+/g, '-')}-${record.version || 'Version'}-Response.json`;
        this.downloadJSON(record.responseExample, filename);
    }

    buildApiPanels(records) {
        const groups = new Map();

        records.forEach((record, index) => {
            const apiKey = record.apiName || record.operationName || record.id || `api-${index}`;
            const normalizedRecord = {
                ...record,
                methodClass: this.getMethodClass(record.apiMethod),
                versionLabel: record.version || 'Unversioned'
            };

            if (!groups.has(apiKey)) {
                groups.set(apiKey, {
                    apiKey,
                    panelId: `panel-${groups.size}`,
                    versions: []
                });
            }

            groups.get(apiKey).versions.push(normalizedRecord);
        });

        return Array.from(groups.values()).map(panel => {
            const versions = this.sortVersions(panel.versions);
            const selectedRecord = versions.find(version => version.isDefault) || versions[0];
            return this.withSelectedRecord({
                ...panel,
                versions,
                selectedVersion: selectedRecord.id,
                selectedRecord,
                versionOptions: versions.map(version => ({
                    label: version.isDefault ? `${version.versionLabel} (Default)` : version.versionLabel,
                    value: version.id
                })),
                hasMultipleVersions: versions.length > 1,
                isExpanded: false
            });
        });
    }

    sortVersions(versions) {
        return [...versions].sort((firstVersion, secondVersion) => {
            if (firstVersion.isDefault !== secondVersion.isDefault) {
                return firstVersion.isDefault ? -1 : 1;
            }

            return this.compareVersionText(secondVersion.versionLabel, firstVersion.versionLabel);
        });
    }

    compareVersionText(firstVersion, secondVersion) {
        const firstParts = firstVersion.split('.').map(part => Number.parseInt(part, 10));
        const secondParts = secondVersion.split('.').map(part => Number.parseInt(part, 10));
        const maxLength = Math.max(firstParts.length, secondParts.length);

        for (let index = 0; index < maxLength; index += 1) {
            const firstPart = Number.isNaN(firstParts[index]) ? 0 : firstParts[index] || 0;
            const secondPart = Number.isNaN(secondParts[index]) ? 0 : secondParts[index] || 0;

            if (firstPart !== secondPart) {
                return firstPart - secondPart;
            }
        }

        return firstVersion.localeCompare(secondVersion);
    }

    withSelectedRecord(panel) {
        const selectedRecord = panel.selectedRecord;
        return {
            ...panel,
            id: selectedRecord.id,
            apiName: selectedRecord.apiName,
            category: selectedRecord.category,
            operationName: selectedRecord.operationName,
            apiMethod: selectedRecord.apiMethod,
            methodClass: selectedRecord.methodClass,
            apiEndpoint: selectedRecord.apiEndpoint,
            version: selectedRecord.version,
            statusCode: selectedRecord.statusCode,
            description: selectedRecord.description,
            eol: selectedRecord.eol,
            requestExample: selectedRecord.requestExample,
            responseExample: selectedRecord.responseExample
        };
    }

    getSelectedRecord(panelId) {
        const panel = this.apiRecords.find(apiPanel => apiPanel.panelId === panelId);
        return panel?.selectedRecord;
    }

    getMethodClass(method) {
        const classMap = {
            'GET': 'method-get',
            'POST': 'method-post',
            'PUT': 'method-put',
            'DELETE': 'method-delete',
            'PATCH': 'method-patch'
        };
        return classMap[method] || 'method-default';
    }

    get groupedByCategory() {
        const grouped = {};
        this.apiRecords.forEach(panel => {
            const category = panel.category || 'Other';
            if (!grouped[category]) {
                grouped[category] = [];
            }
            grouped[category].push(panel);
        });
        return grouped;
    }
}
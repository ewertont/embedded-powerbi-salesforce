import { LightningElement, api, wire } from 'lwc';
import getEmbeddingDataForReport from '@salesforce/apex/PowerBiEmbedManager.getEmbeddingDataForReport';
import powerbijs from '@salesforce/resourceUrl/powerbijs';
import { loadScript } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import RazaoSocial from '@salesforce/schema/User.Account.razaoSocial__c';

export default class PowerBiReport extends LightningElement {
  hasError = false;
  @api pagename = null;
  @api WorkspaceId = ''; //ID WORKSPACE
  @api ReportId = ''; //ID REPORT
  @api AccountRazaoSocial = null;

  //Get pages name from api powerBI -> https://api.powerbi.com/v1.0/myorg/groups/{groupID}/reports/{reportID}/pages/
  // "name": "ReportSectionb00000", "displayName": "Report Page Name"

  @wire(getRecord, { recordId: Id, fields: [RazaoSocial] })
  userDetails({ error, data }) {
    this.loadingData = true;
    if (error) {
      this.hasError = true;
    }
    if (data) {
      this.hasError = false;
      this.AccountRazaoSocial = data.fields.Account.value.fields.razaoSocial__c.value;

      if (this.AccountRazaoSocial !== null && this.WorkspaceId !== null && this.ReportId !== null && this.pagename !== null) {
        getEmbeddingDataForReport({ WorkspaceId: this.WorkspaceId, ReportId: this.ReportId })
          .then((result) => {
            var reportData = result;
            Promise.all([loadScript(this, powerbijs)]).then(() => {
              if (reportData.embedUrl && reportData.embedToken) {
                var reportContainer = this.template.querySelector('[data-id="embed-container"');

                var reportId = reportData.reportId;
                var embedUrl = reportData.embedUrl;
                var token = reportData.embedToken;

                const targetFilter = {
                  $schema: 'http://powerbi.com/product/schema#basic',
                  target: {
                    table: 'customer', //tabela e coluna usada para o filtro.
                    column: 'razaoSocial',
                  },
                  operator: 'In',
                  values: [this.AccountRazaoSocial], //filter by AccountRazaoSocial
                  filterType: 1, //basicType
                  requireSingleSelection: false,
                };

                var config = {
                  type: 'report',
                  id: reportId,
                  pageName: this.pagename,
                  filters: [targetFilter],
                  embedUrl: embedUrl,
                  accessToken: token,
                  tokenType: 1,
                  settings: {
                    filterPaneEnabled: false,
                    navContentPaneEnabled: false,
                    panes: {
                      filters: { visible: false },
                      pageNavigation: { visible: false },
                    },
                  },
                };

                // Embed the report and display it within the div container.
                var report = powerbi.embed(reportContainer, config);
              } else {
                this.hasError = true;
              }
            });
          })
          .catch((error) => {
            this.hasError = true;
          });
      }
    }
  }
}

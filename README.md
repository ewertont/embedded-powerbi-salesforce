# Embedded PowerBI on SalesForce Experience Cloud

É um projeto simples utilizado para apresentar os relatórios do Power BI através de um componente LWC no SalesForce Experience Cloud via iframe autenticado. 
Foi utilizado como base o repositório [SalesforceAppOwnsDataEmbedding](https://github.com/PowerBiDevCamp/SalesforceAppOwnsDataEmbedding), aqui trago algumas alterações e passo a passo do que foi realizado para implementação.

O principal objetivo desse repositório é apenas trazer facilidade no momento de implementar um relatório embbedado do PowerBI no SF.

## Configuration

Faça upload do "powerbijs.js" em Static Resources e configure como Public.

```bash
Setup -> Static Resources -> New
```

Crie um novo Custom Metadata Type

```bash
Setup -> Custom Metadata Types -> New Custom Metadata Type 
```

<img src="images\readme\step1.png" style="width:6.24324in;height:1.53896in" />

##

Crie um novo registro com as informações de autenticação do seu ambiente/usuário no PowerBI.

```bash
Setup -> Custom Metadata Types -> Power BI Auth Setting -> Manage Records -> New 	
```

<img src="images\readme\step2.png" style="width:6.24324in;height:1.53896in" />

##

Adicione o domínio do PowerBI ao Trusted URLs no setup.

```bash
Setup -> Trusted URLs -> New Trusted URLs	
```
<img src="images\readme\step3.png" style="width:6.24324in;height:1.53896in" />

##

Adicione as URL's remotas do AzureAD e PowerBI as configurações de Remote Sites no SalesForce.

```bash
Setup -> Remote Site Settings -> New Remote Site	
```
<img src="images\readme\step4-1.png" style="width:6.24324in;height:1.53896in" />
 
###

<img src="images\readme\step4-2.png" style="width:6.24324in;height:1.53896in" />


## Usage

Após finalizar as etapas de configuração no setup do SF, é necessário realizar as alterações dentro da classe/componente LWC.
Na classe "PowerBiEmbedManager", está configurado para realizar autenticação utilizando "password", caso deseje alterar para utilizar client_secret basta alterar o "grant_type" para "client_credentials"

<img src="images\readme\granttype.png" style="width:6.24324in;height:1.53896in" />

###
Caso deseje utilizar DataSetID, altere nesta linha:

<img src="images\readme\datasetid.png" style="width:6.24324in;height:1.53896in" />

###
Este LWC está configurado para receber o WorkSpaceID e o ReportID através de uma property, mas caso deseje pode ser inserido dentro do próprio componente.

<img src="images\readme\workspaceid.png" style="width:6.24324in;height:1.53896in" />

###
Os relatórios estão sendo filtrados através de uma coluna na tabela customer, como mostro abaixo.

<img src="images\readme\filter.png" style="width:6.24324in;height:1.53896in" />

###
Também é possível adicionar uma Page especifica do relatório, caso deseje só é preciso buscar o pageName da pagina que deseja através dessa chamada abaixo.
```bash
https://api.powerbi.com/v1.0/myorg/groups/{groupID}/reports/{reportID}/pages/
```
###
<img src="images\readme\pagename.png" style="width:6.24324in;height:1.53896in" />



## Reference

[Power BI REST API's Public Workspace
](https://www.postman.com/power-bi/workspace/power-bi-rest-api-s-public-workspace/collection/3238008-03c5ba56-69a2-489c-af33-0ef101c577ec)

[SalesforceAppOwnsDataEmbedding](https://github.com/PowerBiDevCamp/SalesforceAppOwnsDataEmbedding)

[API--access-powerbi-without-login](https://github.com/athempeed/API--access-powerbi-without-login/tree/master)



## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)

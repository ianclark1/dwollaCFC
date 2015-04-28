<cfcomponent displayname="dwollaCFC">
<!---
@Created by: Allyn j. Alford
@Email:Allyn@TheCovetedGroup.com
@Date: 3/24/2011
@Description: Dwolla API comsumption CFC. Used to interact with Dwolla Webservices.


Required:
	1. Dwolla Account: Valid Dwolla.com account
	2. Dwolla ApiKey: Aplha-Numeric string
	3. Dwolla ApiCode: Alpha-Numeric string
	4. Dwolla Webservice URL: These url's are the ones used to develop this CFC. 
		The SOAPAction namespace has been hard code based on this "http://tempuri.org/IApi/ + OperationName"
		a. TestURL: https://www.dwolla.com/api/TestAPI.svc
		b. ProdURL: https://www.dwolla.com/api/API.svc
		
		
		
Quick Start

1. You'll need to create an object representation of the TWO CFC'S
xmlObj = CreateObject("component","xml2struct");
DwollaObj = CreateObject("component","dwollaCFC").init(xmlObj,'DWOLLA_ApiKey','DWOLLA_ApiCode');

This function takes Four(6) parameters, requires only Three(4) to initailize and return a Dwolla Object
		1. An xml2struct Object. You can download it from (http://xml2struct.riaforge.org/)
		2. The url to the Webservice, this is the URL that's listed on the Dwolla.com site (http://www.dwolla.org/dev/api/soap). The above listed URL's are a prefect example.
		3. The ApiKey that's sent to you from Dwolla (http://www.dwolla.org/dev/forms/request-api-key)
		4. The ApiCode that's sent to you from Dwolla (http://www.dwolla.org/dev/forms/request-api-key)
		5. (NOT REQUIRED) is used to change the URI of the Soap Action, ONLY IF YOU WISH TO CHANGE IT
		6. (NOT REQUIRED) is used to change the URI of the Schema, ONLY IF YOU WISH TO CHANGE IT

2. Call any function you wish. (SendMoney, RequestPaymentKey, ConfirmPayment, SendMoneyAssumeCosts, VerifyPaymentKey)


<cfoutput>#Now()#</cfoutput>

<cfscript>
xmlObj = CreateObject("component","xml2struct");
obj = CreateObject("component","dwollaCFC").init(xmlObj,'yourKey','yourCode');

sm = obj.sendMoney('1.00','test','123456789');
</cfscript>
<cfdump var="#sm#">			 
			
	
--->

         <cffunction name="init" returntype="dwollaCFC">
           <cfargument name="xml2struct" type="xml2struct" required="yes">
           <cfargument name="ApiKey" type="string" required="yes">
           <cfargument name="ApiCode" type="string" required="yes">
           <cfargument name="url" type="string" required="no">
           <cfargument name="soapActionUri" type="string" required="no">
           <cfargument name="schemaUri" type="string" required="no">
           <cfscript>
            variables.url = StructFind(arguments,"url");
            variables.ApiKey = StructFind(arguments,"ApiKey");
            variables.ApiCode = StructFind(arguments,"ApiCode");
			variables.xml2Struct = StructFind(arguments,'xml2Struct');
			
			if(StructKeyExists(arguments,'url') AND StructFind(arguments,'url') NEQ ""){
				   variables.url = StructFind(arguments,'url');
				   variables.customUrl = true;
			  }else{
				   variables.url = "https://www.dwolla.com/api/TestAPI.svc";
				   variables.customUrl = false;
			  }
			
			
			
				if(StructKeyExists(arguments,'soapActionUri')){
				
				  variables.soapActionUri = StructFind(arguments,'soapActionUri');
				  
				 }else{
				 
				  variables.soapActionUri = "http://tempuri.org/IApi/";
				  
				 }
			 
				 if(StructKeyExists(arguments,'schemaUri') AND StructFind(arguments,'schemaUri') NEQ ""){
				 
				   variables.schemaUri = StructFind(arguments,'schemaUri');
				   
				  }else{
				  
				   variables.schemaUri = "http://tempuri.org/";
				   
				  }
				  			  
			return this;
           </cfscript>
         </cffunction>

	<cffunction name="SendMoney" access="public" returntype="struct">
		<cfargument name="Amount" type="string" required="yes">
        <cfargument name="Description" type="string" required="yes">
        <cfargument name="DestinationID" type="string" required="yes">
		 <cfsavecontent variable="soap">
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="<cfoutput>#StructFind(variables,'schemaUri')#</cfoutput>">
               <soapenv:Body>
                  <tem:SendMoney>
					<cfoutput>                     
				     <tem:ApiKey>#StructFind(variables,"ApiKey")#</tem:ApiKey>
                     <tem:ApiCode>#StructFind(variables,"ApiCode")#</tem:ApiCode>
                     <tem:Amount>#StructFind(arguments,"Amount")#</tem:Amount>
                     <tem:Description>#StructFind(arguments,"Description")#</tem:Description>
                     <tem:DestinationID>#StructFind(arguments,"DestinationID")#</tem:DestinationID>
					</cfoutput>
                  </tem:SendMoney>
               </soapenv:Body>
            </soapenv:Envelope>
         </cfsavecontent>
         <cfscript>
		  results = StructNew();	
		  results.result = variables.xml2Struct.ConvertXmlToStruct(sendRequest(StructFind(variables,'soapActionUri') & 'SendMoney', soap),StructNew());
		  if(NOT StructKeyExists(results.result.Body,'Fault')){
			  results.success = results.result.Body.SendMoneyResponse.SendMoneyResult;
		     return results;
		   }else{
		      results.success = false;
		      results.message =  results.result.Body.Fault.detail.ExceptionDetail.Message;
		      results.type = results.result.Body.Fault.detail.ExceptionDetail.Type;
		    return results;
		   }
		 </cfscript>
	</cffunction>
    
    
     <cffunction name="RequestPaymentKey" access="public" returntype="struct">
		<cfargument name="Amount" type="string" required="yes">
        <cfargument name="Description" type="string" required="yes">
        <cfargument name="CustomerID" type="string" required="yes">
		 <cfsavecontent variable="soap">
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="<cfoutput>#StructFind(variables,'schemaUri')#</cfoutput>">
               <soapenv:Body>
                  <tem:RequestPaymentKey>
					<cfoutput>                     
				     <tem:ApiKey>#StructFind(variables,"ApiKey")#</tem:ApiKey>
                     <tem:ApiCode>#StructFind(variables,"ApiCode")#</tem:ApiCode>
                     <tem:Amount>#StructFind(arguments,"Amount")#</tem:Amount>
                     <tem:Description>#StructFind(arguments,"Description")#</tem:Description>
                     <tem:CustomerID>#StructFind(arguments,"CustomerID")#</tem:CustomerID>
					</cfoutput>
                  </tem:RequestPaymentKey>
               </soapenv:Body>
            </soapenv:Envelope>
         </cfsavecontent>
         <cfscript>
		  results = StructNew();
		  results.result = variables.xml2Struct.ConvertXmlToStruct(sendRequest(StructFind(variables,'soapActionUri') & 'RequestPaymentKey', soap),StructNew());
		  if(NOT StructKeyExists(results.result.Body,'Fault')){
			  results.success = results.result.Body.RequestPaymentKeyResponse.RequestPaymentKeyResult;
		     return results;
		   }else{
		      results.success = false;
		      results.message =  results.result.Body.Fault.detail.ExceptionDetail.Message;
		      results.type = results.result.Body.Fault.detail.ExceptionDetail.Type;
		    return results;
		   }
		 </cfscript>
	</cffunction>
    
      <cffunction name="ConfirmPayment" access="public" returntype="struct">
		<cfargument name="Amount" type="string" required="yes">
        <cfargument name="CustomerID" type="string" required="yes">
        <cfargument name="PaymentKey" type="string" required="yes">
		 <cfsavecontent variable="soap">
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="<cfoutput>#StructFind(variables,'schemaUri')#</cfoutput>">
               <soapenv:Body>
                  <tem:ConfirmPayment>
					<cfoutput>                     
				     <tem:ApiKey>#StructFind(variables,"ApiKey")#</tem:ApiKey>
                     <tem:ApiCode>#StructFind(variables,"ApiCode")#</tem:ApiCode>
                     <tem:Amount>#StructFind(arguments,"Amount")#</tem:Amount>
                     <tem:CustomerID>#StructFind(arguments,"CustomerID")#</tem:CustomerID>
                     <tem:PaymentKey>#StructFind(arguments,"PaymentKey")#</tem:PaymentKey>
					</cfoutput>
                  </tem:ConfirmPayment>
               </soapenv:Body>
            </soapenv:Envelope>
         </cfsavecontent>
          <cfscript>
		  results = StructNew();
		  results.result = variables.xml2Struct.ConvertXmlToStruct(sendRequest(StructFind(variables,'soapActionUri') & 'ConfirmPayment', soap),StructNew());
		  if(NOT StructKeyExists(results.result.Body,'Fault')){
			  results.success = results.result.Body.ConfirmPaymentResponse.ConfirmPaymentResult;
		     return results;
		   }else{
		      results.success = false;
		      results.message =  results.result.Body.Fault.detail.ExceptionDetail.Message;
		      results.type = results.result.Body.Fault.detail.ExceptionDetail.Type;
		    return results;
		   }
		 </cfscript>
	</cffunction>
    
       <cffunction name="SendMoneyAssumeCosts" access="public" returntype="struct">
		<cfargument name="Amount" type="string" required="yes">
        <cfargument name="Description" type="string" required="yes">
        <cfargument name="DestinationID" type="string" required="yes">
		 <cfsavecontent variable="soap">
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="<cfoutput>#StructFind(variables,'schemaUri')#</cfoutput>">
               <soapenv:Body>
                  <tem:SendMoneyAssumeCosts>
					<cfoutput>                     
				     <tem:ApiKey>#StructFind(variables,"ApiKey")#</tem:ApiKey>
                     <tem:ApiCode>#StructFind(variables,"ApiCode")#</tem:ApiCode>
                     <tem:Amount>#StructFind(arguments,"Amount")#</tem:Amount>
                     <tem:Description>#StructFind(arguments,"Description")#</tem:Description>
                     <tem:DestinationID>#StructFind(arguments,"DestinationID")#</tem:DestinationID>
					</cfoutput>
                  </tem:SendMoneyAssumeCosts>
               </soapenv:Body>
            </soapenv:Envelope>
         </cfsavecontent>
          <cfscript>
		  results = StructNew();
		  results.result = variables.xml2Struct.ConvertXmlToStruct(sendRequest(StructFind(variables,'soapActionUri') & 'SendMoneyAssumeCosts', soap),StructNew());
		  if(NOT StructKeyExists(results.result.Body,'Fault')){
			  results.success = results.result.Body.SendMoneyAssumeCostsResponse.SendMoneyAssumeCostsResult;
		     return results;
		   }else{
		      results.success = false;
		      results.message =  results.result.Body.Fault.detail.ExceptionDetail.Message;
		      results.type = results.result.Body.Fault.detail.ExceptionDetail.Type;
		    return results;
		   }
		 </cfscript>
	</cffunction>
    
    
       <cffunction name="VerifyPaymentKey" access="public" returntype="struct">
		<cfargument name="Amount" type="string" required="yes">
        <cfargument name="CustomerID" type="string" required="yes">
        <cfargument name="PaymentKey" type="string" required="yes">
		 <cfsavecontent variable="soap">
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="<cfoutput>#StructFind(variables,'schemaUri')#</cfoutput>">
               <soapenv:Body>
                  <tem:VerifyPaymentKey>
					<cfoutput>                     
				     <tem:ApiKey>#StructFind(variables,"ApiKey")#</tem:ApiKey>
                     <tem:ApiCode>#StructFind(variables,"ApiCode")#</tem:ApiCode>
                     <tem:Amount>#StructFind(arguments,"Amount")#</tem:Amount>
                     <tem:CustomerID>#StructFind(arguments,"CustomerID")#</tem:CustomerID>
                     <tem:PaymentKey>#StructFind(arguments,"PaymentKey")#</tem:PaymentKey>
					</cfoutput>
                  </tem:VerifyPaymentKey>
               </soapenv:Body>
            </soapenv:Envelope>
         </cfsavecontent>
          <cfscript>
		  results = StructNew();
		  results.result = variables.xml2Struct.ConvertXmlToStruct(sendRequest(StructFind(variables,'soapActionUri') & 'VerifyPaymentKey', soap),StructNew());
		  if(NOT StructKeyExists(results.result.Body,'Fault')){
			  results.success = results.result.Body.VerifyPaymentKeyResponse.VerifyPaymentKeyResult;
		     return results;
		   }else{
		      results.success = false;
		      results.message =  results.result.Body.Fault.detail.ExceptionDetail.Message;
		      results.type = results.result.Body.Fault.detail.ExceptionDetail.Type;
		    return results;
		   }
		 </cfscript>
	</cffunction>
    
    
    <cffunction name="setProductionMode" access="public" returntype="boolean">
      <cfargument name="mode" type="boolean" required="no">
      <cfscript>
	    if(StructKeyExists(arguments,'mode') AND StructFind(arguments,'mode') NEQ "" AND NOT variables.customUrl){
		    
			if(StructFind(arguments,'mode') EQ "false" or StructFind(arguments,'mode') EQ False){
		      variables.productionMode = false;
		      variables.url = "https://www.dwolla.com/api/TestAPI.svc";
			  }else if(StructFind(arguments,'mode') EQ "true" or StructFind(arguments,'mode') EQ True) {
			   variables.productionMode = true;
		       variables.url = "https://www.dwolla.com/api/API.svc";
			  }
		 
		}else if( NOT StructKeyExists(arguments,'mode') AND NOT variables.customUrl ){
		 variables.productionMode = true;
		 variables.url = "https://www.dwolla.com/api/API.svc";
		}
		
		return isProductionMode();
	  </cfscript>
    </cffunction>
    
     <cffunction name="isProductionMode" access="public" returntype="boolean">
      <cfscript>
	  	  if(StructKeyExists(variables,'productionMode')){
		   return StructFind(variables,'productionMode');
		  }else{
		    setProductionMode(false);
			return false;
		  }
	  </cfscript>
    </cffunction>
    
    
    
    <cffunction name="sendRequest" access="private" returntype="any">
        <cfargument name="action" type="string" required="yes">
        <cfargument name="soap" type="xml" required="yes">
        <cfhttp url="#StructFind(variables,'url')#" method="post">
          <cfhttpparam type="header" name="SOAPAction" value="#StructFind(arguments,'action')#">
          <cfhttpparam type="xml" name="message" value="#trim(StructFind(arguments,'soap'))#">
        </cfhttp>
        <cfreturn cfhttp.FileContent>
    </cffunction>
    
    
</cfcomponent>
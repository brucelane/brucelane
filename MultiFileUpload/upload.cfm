

<!--- 
Flex Multi-File Upload Server Side File Handler 

This file is where the upload action from the Flex Multi-File Upload UI points.
This is the handler the server side half of the upload process.
--->


<cftry>

<!--- 
Because flash uploads all files with a binary mime type ("application/ocet-stream") we cannot set cffile to accept specfic mime types.
The workaround is to check the file type after it arrives on the server and if it is non desireable delete it.
--->
	<cffile action="upload" 
			filefield="filedata" 
			destination="#ExpandPath('\')#MultiFileUpload\uploadedfiles\" 
			nameconflict="makeunique" 
			accept="application/octet-stream"/>
		
		<!--- Begin checking the file extension of uploaded files --->
		<cfset acceptedFileExtensions = "jpg,jpeg,gif,png,pdf,flv,txt,doc,rtf"/>
		<cfset filecheck = listFindNoCase(acceptedFileExtensions,File.ServerFileExt)/>

<!--- 
If the variable filecheck equals false delete the uploaded file immediatley as it does not match the desired file types
--->
		<cfif filecheck eq false>
			<cffile action="delete" file="#ExpandPath('\')#MultiFileUpload\uploadedfiles\#File.ServerFile#"/>
		</cfif>
		
<!--- 
Should any error occur output a pdf with all the details.
It is difficult to debug an error from this file because no debug information is 
diplayed on page as its called from within the Flash UI.  If your files are not uploading check 
to see if an errordebug.pdf has been generated.
--->
		<cfcatch type="any">
			<cfdocument format="PDF" overwrite="yes" filename="errordebug.pdf">
				<cfdump var="#cfcatch#"/>
			</cfdocument>
		</cfcatch>
</cftry>

<!---- UPLOAD PHOTO EN PROVENANCE DU FORMULAIRE ---->

<a href="upload.cfm">actualiser</a>
<BR><BR>

<cfif isdefined("theFile")>
  <cfif len(trim('#theFile#')) gt 0>
    <cffile action="upload" nameconflict = "MakeUnique" destination="d:\wwwroot\photos3D\uploads\" filefield="theFile">
    <cfset lefichierjoint = lcase(trim('#cffile.serverfile#'))>
  </cfif>


<cfelse> 


<cfif isdefined("form.theFile")>
  <cfif len(trim('#form.theFile#')) gt 0>
    <cffile action="upload" nameconflict = "MakeUnique" destination="d:\wwwroot\photos3D\uploads\" filefield="theFile">
    <cfset lefichierjoint = lcase(trim('#cffile.serverfile#'))>
  </cfif>
</cfif> 

</cfif>



<!---- SI SUP IMAGE PREVENANT DU LIEN ---->
<cfif isdefined("supimg")>
  <cffile action = "delete" file = "d:\wwwroot\photos3D\uploads\#supimg#">
</cfif> 



<!---- FORMULAIRE ENVOI PHOTO ---->
<FORM ACTION="upload.cfm" METHOD=POST enctype="multipart/form-data">
Envoyer une photo JPG<BR>
<input type="File" size=30 name="theFile" value=""/>
<INPUT TYPE="submit" VALUE="Envoyer la photo">
</FORM>

<BR>
<HR>
<BR>

<!---- LECTURE DISK ---->
<cfdirectory directory="d:/wwwroot/photos3D/uploads/" action="list" filter="*.jpg" name="listfile">
<TABLE border=1>
<TR bgcolor="#c0c0c0">
<TD>Fichier JPG</TD>
<TD>Size (octets)</TD>
<TD>Date modification</TD>
<TD>&nbsp;</TD>
</TR> 
<cfloop query="listfile">
<TR>
<TD><cfoutput><a href="#name#">#name#</a></cfoutput></TD>
<TD><cfoutput>#size#</cfoutput></TD>
<TD><cfoutput>#datelastmodified#</cfoutput></TD>
<TD><cfoutput><a href="upload.cfm?supimg=#name#">Supprimer</a></cfoutput></TD>
</TR> 
</cfloop>
<TABLE>
<BR>
<HR>
<BR>


<%@ page import="java.net.MalformedURLException,
                 java.util.*,
                 org.apache.commons.fileupload.DiskFileUpload,
                 org.apache.commons.fileupload.FileItem,
                 org.tttalk.openfire.plugin.TTTalkUserBatchPlugin,
                 org.jivesoftware.openfire.XMPPServer,
                 org.jivesoftware.util.ParamUtils"
%>

<%
	boolean createGroups = request.getParameter("createGroups") != null;
	boolean importGroups = request.getParameter("importGroups") != null;
   
    TTTalkUserBatchPlugin plugin = (TTTalkUserBatchPlugin) XMPPServer.getInstance().getPluginManager().getPlugin("tttalk.userbatch");
    List<String> invalidGroups = new ArrayList<String>();
   
    Map<String, String> errors = new HashMap<String, String>();
    if (createGroups) {
    	String data = request.getParameter("data");
    	if (data.trim().length() == 0){
    		errors.put("emptyData", "emptyData");
    	}else{
        	invalidGroups.addAll(plugin.createGroups(data));
        	
        	if (invalidGroups.size() == 0) {
                response.sendRedirect("create-groups.jsp?success=true");
                return;
            }
            
            errors.put("invalidGroup", "invalidGroup");
    	}        
	} else if (importGroups) {
        DiskFileUpload dfu = new DiskFileUpload();
      
        List fileItems = dfu.parseRequest(request);
        Iterator i = fileItems.iterator();
        FileItem fi = (FileItem) i.next();
        plugin.importGroupData(fi);
        response.sendRedirect("create-groups.jsp?success=true");
	}
%>

<html>
    <head>
        <title>Create TTTalk Group Data</title>
        <meta name="pageID" content="tttalk-create"/>
    </head>
    <style>
	    ::-webkit-input-placeholder::before {
		  content: "groupname_1\000Agroupname_2\000Agroupname_3";
		}
		
		::-moz-placeholder::before {
		  content: "groupname_1\000Agroupname_2\000Agroupname_3";
		}
		
		:-ms-input-placeholder::before {
		  content: "groupname_1\000Agroupname_2\000Agroupname_3";
		}
    </style>
    <body>

<% if (errors.size() > 0) { %>

    <div class="jive-error">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr>
            <td class="jive-icon"><img src="images/error-16x16.gif" width="16" height="16" border="0"></td>
            <td class="jive-icon-label">
            <% if (errors.containsKey("emptyData")) { %>
               Please input groupname list.<br>
            <% }else if (errors.containsKey("invalidGroup")) { %>
               The following groups already exist in the system or have invalid groupname:<br>
            <%
                Iterator iter = invalidGroups.iterator();
                while (iter.hasNext()) {
                    String groupname = (String) iter.next();
                    %><%= groupname %><%
                    if (iter.hasNext()) {
                        %>,&nbsp;<%
                    } else {
                        %>.<%
                    }
                }
            } %>
            </td>
        </tr>
        </tbody>
    </table>
    </div>
    <br>

<% } else if (ParamUtils.getBooleanParameter(request, "success")) { %>

    <div class="jive-success">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr>
            <td class="jive-icon"><img src="images/success-16x16.gif" width="16" height="16" border="0"></td>
            <td class="jive-icon-label">All groups added successfully.</td>
        </tr>
        </tbody>
    </table>
    </div>
    <br>

<% } %>

<form action="create-groups.jsp?createGroups=true" method="post" >

<div class="jive-contentBoxHeader">Create</div>
<div class="jive-contentBox">
    <textarea name="data" rows="10" style="width:50%" placeholder=" "></textarea>
</div>
<input type="submit" value="Create">

</form>

<form action="create-groups.jsp?importGroups=true" method="post" enctype="multipart/form-data">
	<div class="jive-contentBoxHeader">Import</div>
	<div class="jive-contentBox">
	    Choose a file to import:</p>
	    <input type="file" name="thefile">
	</div>
	<input type="submit" value="Import">

</form>

</body>
</html>


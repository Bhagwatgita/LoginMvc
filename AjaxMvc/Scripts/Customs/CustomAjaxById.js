/// <reference path="../jquery-1.10.2.min.js" />
$(document).ready(function() {
            $("#load").hide();
            $("#errorDiv").hide();
            $("#successDiv").hide();
});
    function OnBegin() {
        $("#load").show();
        $("#errorDiv").hide();
        $("#successDiv").hide();
    }

    function OnSuccess(data) {
        if (data.ErrorCode == '1') {
            $("#load").hide();
            $("#errorDiv").show();
            $("#successDiv").hide();
            $("#errorMsg").text(data.Msg);
        }
        else if (data.ErrorCode == '0')
        {
            $("#load").hide();
            $("#successDiv").show();
            $("#errorDiv").hide();
            $("#successMsg").text(data.Msg); 
        }
        else
        {
             $("#load").hide();
            $("#errorDiv").show();
            $("#successDiv").hide();
            $("#errorMsg").text(data.Msg);
        }
   
}
    
function OnFailure(data) {
    swal({
        title: 'Error',
        text: 'OOPS!! Something happened + error',
        type: 'error',
        confirmButtonText: 'ok'
    });
}

  
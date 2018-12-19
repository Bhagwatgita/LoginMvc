$(document).ready(function() {
            $("#load").hide();
            $("#errorDiv").hide();
            $("#successDiv").hide();
});
    function OnBegin() {
    swal({ text: 'Please wait ...' });
}

    function OnSuccess(data) {
        if (data.ErrorCode == '1') {
             swal({
                title: 'Error',
                text: data.Msg,
                type: 'error',
                confirmButtonColor: "#DD6B55",
                confirmButtonText: 'ok'
            });
        }
        else if (data.ErrorCode == '0')
        {
            swal({
                    title: '',
                    text: data.Msg,
                    type: 'success',
                    confirmButtonColor:"#a5dc86",
                    confirmButtonText: 'Ok'
                },
                function(isConfirm) {
                    if (isConfirm) {
                        location.reload(true);
                    }
                });
        }
        else
        {
            swal({
                title: 'Error',
                text: data.Msg,
                type: 'error',
                confirmButtonColor: "#DD6B55",
                confirmButtonText: 'ok'
            });
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

  
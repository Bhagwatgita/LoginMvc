using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AjaxMvc.Models
{
    public class LoginDao : ApplicationDao
    {

        public DbResult DoLogin(string Username,string Password,string IpAddress)
        {
            var sql = "EXEC proc_applicationLogin @flag='l'";
            sql += ",@userName=" + FilterString(Username);
            sql += ",@pwd=" + FilterString(Password);
            sql += ",@ipAddress=" + FilterString(IpAddress);
            var result = ParseDbResult(sql);
            return result;
        }
    }

    //public class Credentials
    //{
    //    public string Username { get; set; }
    //    public string Password { get; set; }
    //    public string IpAddress { get;set;}
    //}


    

}
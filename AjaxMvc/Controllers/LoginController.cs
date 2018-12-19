using AjaxMvc.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AjaxMvc.Controllers
{
    public class LoginController : Controller
    {
        private LoginDao _dao;
        public LoginController()
        {
                _dao=new LoginDao();
        }
        // GET: Login
        public ActionResult Index()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Index(string username,string password)
        {

            var dr = _dao.DoLogin(username,password,IpAddress:Request.UserHostAddress);
            if (!dr.ErrorCode.Equals("0"))
            {
                return Json(dr, JsonRequestBehavior.AllowGet);
            }

            return Json(dr, JsonRequestBehavior.AllowGet);
        }

    }
}
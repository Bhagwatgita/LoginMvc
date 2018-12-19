using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using AjaxMvc.Models;

namespace AjaxMvc.Controllers
{
    public class FeatureController : Controller
    {
        FeatureOperationDao _dao=new FeatureOperationDao();
        // GET: Feature
        public ActionResult Index()
        {
            return View();
        }
        [HttpGet]
        public ActionResult Add()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Add(string FeatureName)
        {
            var dr = _dao.UpdateFeature(FeatureName);
            if (!dr.ErrorCode.Equals("0"))
            {
                return Json(dr, JsonRequestBehavior.AllowGet);
            }
            
            return Json(dr, JsonRequestBehavior.AllowGet);  
        }
    }
}
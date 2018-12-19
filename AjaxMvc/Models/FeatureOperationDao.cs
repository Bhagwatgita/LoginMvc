using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;

namespace AjaxMvc.Models
{
    public class FeatureOperationDao: ApplicationDao
    {
        private ApplicationDao _dao;
        public FeatureOperationDao()
        {
                _dao=new ApplicationDao();
        }

        public DbResult UpdateFeature(string name)
        {
            var sql = "EXEC proc_Feature @flag='i'";
            sql += ",@name=" + _dao.FilterString(name);
            var result=_dao.ParseDbResult(sql);
            return result;
        }
    }
}
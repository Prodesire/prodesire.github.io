<p><div id="top"></div></p>
<script src="https://cdn1.lncld.net/static/js/av-core-mini-0.6.4.js"></script>
<script>AV.initialize("r5ofSrw8CXJUtyUOC54bkMuy-gzGzoHsz", "YcMCWnPYP6XWogWEbRBSNbfI");</script>
<script type="text/javascript">
  var time=0
  var title=""
  var url=""
  var query = new AV.Query('Counter');
  query.notEqualTo('id',0);
  query.descending('time');
  query.limit(1000);
  query.find().then(function (todo) {
    for (var i=0;i<1000;i++){
      var result=todo[i].attributes;
      time=result.time;
      title=result.title;
      url=result.url;
      var content="<p>"+"<font color='#1C1C1C'>"+"【阅读量: "+time+" 】"+"</font>"+"<a href='"+"https://prodesire.cn"+url+"'>"+title+"</a>"+"</p>";
      document.getElementById("top").innerHTML+=content
    }
  }, function (error) {
    console.log(error);
  });
</script>

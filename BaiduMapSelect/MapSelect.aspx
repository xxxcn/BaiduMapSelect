﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MapSelect.aspx.cs" Inherits="BaiduMapSelect.MapSelect" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <style type="text/css">
        body, html, #allmap {
            width: 100%;
            height: 95%;
            overflow: hidden;
            margin: 0;
            font-family: "微软雅黑";
        }
    </style>
    <script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=5E5EE28a7615536d1ffe2ce2a3667859"></script>
    <!--加载鼠标绘制工具-->
    <script type="text/javascript" src="http://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.js"></script>
    <link rel="stylesheet" href="http://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.css" />
    <!--加载检索信息窗口-->
    <%--<script type="text/javascript" src="http://api.map.baidu.com/library/SearchInfoWindow/1.4/src/SearchInfoWindow_min.js"></script>
	<link rel="stylesheet" href="http://api.map.baidu.com/library/SearchInfoWindow/1.4/src/SearchInfoWindow_min.css" />--%>
    <%--<script type="text/javascript" src="http://api.map.baidu.com/library/GeoUtils/1.2/src/GeoUtils_min.js"></script>--%>
    <script type="text/javascript" src="http://api.map.baidu.com/library/TextIconOverlay/1.2/src/TextIconOverlay_min.js"></script>
    <script type="text/javascript" src="http://api.map.baidu.com/library/MarkerClusterer/1.2/src/MarkerClusterer_min.js"></script>
</head>
<body>
    <div id="allmap" style="overflow: hidden; zoom: 1; position: relative;">
        <div id="map" style="height: 95%; -webkit-transition: all 0.5s ease-in-out; transition: all 0.5s ease-in-out;"></div>
    </div>
    <input type="button" value="清除所有覆盖物" onclick="clearAll()" />
    <input type="button" value="获取区域选择的标注点集合" onclick="getOverlayPath()" />
    <script type="text/javascript">

        // 百度地图API功能
        var map = new BMap.Map("map");
        var point = new BMap.Point(113.323685, 23.130522);
        map.centerAndZoom(point, 15);
        //map.centerAndZoom(point, 8);

        map.enableScrollWheelZoom(true);     //开启鼠标滚轮缩放
        // 编写自定义函数,创建标注
        function addMarker(point, id) {
            var marker = new BMap.Marker(point);
            map.addOverlay(marker);
            addClickHandler("id为:" + id, marker);
        }
        var opts = {
            width: 100,     // 信息窗口宽度
            height: 80,     // 信息窗口高度
            title: "信息窗口", // 信息窗口标题
            enableMessage: false//设置允许信息窗发送短息
        };
        function addClickHandler(content, marker) {
            marker.addEventListener("click", function (e) {
                openInfo(content, e)
            }
            );
        }
        function openInfo(content, e) {
            var p = e.target;
            var point = new BMap.Point(p.getPosition().lng, p.getPosition().lat);
            var infoWindow = new BMap.InfoWindow(content, opts);  // 创建信息窗口对象 
            map.openInfoWindow(infoWindow, point); //开启信息窗口
        }
        // 随机向地图添加25个标注
        var bounds = map.getBounds();
        var sw = bounds.getSouthWest();
        var ne = bounds.getNorthEast();
        var lngSpan = Math.abs(sw.lng - ne.lng);
        var latSpan = Math.abs(ne.lat - sw.lat);
        var allPointArray = [];
        var markers = [];
        for (var i = 0; i < 20; i++) {
            var point = new BMap.Point(sw.lng + lngSpan * (Math.random() * 0.7), ne.lat - latSpan * (Math.random() * 0.7));
            allPointArray.push({ Point: point, Id: i });
            addMarker(point, i);

            //markers.push(point);
        }

        //最简单的用法，生成一个marker数组，然后调用markerClusterer类即可。
        //var markerClusterer = new BMapLib.MarkerClusterer(map, { markers: markers });

        var overlays = [];
        var overlaycomplete = function (e) {
            clearAll();
            overlays.push(e.overlay);
            e.overlay.enableEditing();
            e.overlay.addEventListener("lineupdate", function (e) {
                showLatLon(e.currentTarget);
            });
            var pointArray = e.overlay.getPath();
            map.setViewport(pointArray);//调整视野
        };
        var styleOptions = {
            strokeColor: "red",    //边线颜色。
            fillColor: "red",      //填充颜色。当参数为空时，圆形将没有填充效果。
            strokeWeight: 2,       //边线的宽度，以像素为单位。
            strokeOpacity: 0.5,	   //边线透明度，取值范围0 - 1。
            fillOpacity: 0.3,      //填充的透明度，取值范围0 - 1。
            strokeStyle: 'solid' //边线的样式，solid或dashed。
        }
        //实例化鼠标绘制工具
        var drawingManager = new BMapLib.DrawingManager(map, {
            isOpen: false, //是否开启绘制模式
            enableDrawingTool: true, //是否显示工具栏
            drawingToolOptions: {
                anchor: BMAP_ANCHOR_TOP_RIGHT, //位置
                offset: new BMap.Size(5, 5), //偏离值
            },
            circleOptions: styleOptions, //圆的样式
            polylineOptions: styleOptions, //线的样式
            polygonOptions: styleOptions, //多边形的样式
            rectangleOptions: styleOptions //矩形的样式
        });
        //添加鼠标绘制工具监听事件，用于获取绘制结果
        drawingManager.addEventListener('overlaycomplete', overlaycomplete);
        function clearAll() {
            for (var i = 0; i < overlays.length; i++) {
                map.removeOverlay(overlays[i]);
            }
            overlays.length = 0;
        }
        function getOverlayPath() {
            var box = overlays[overlays.length - 1];
            var pointArray = box.getPath();
            map.setViewport(pointArray);//调整视野

            var bound = map.getBounds();//地图可视区域
            var s = "圈选的ID有:";
            for (var i = 0; i < allPointArray.length; i++) {
                if (bound.containsPoint(allPointArray[i].Point) == true) {
                    if (isInsidePolygon(allPointArray[i].Point, pointArray))
                        s += allPointArray[i].Id + ",";
                }
            }
            alert(s);
        }
        var overlaysCache = [];
        function showLatLon(a) {
            var len = a.length;
            var arr = [];
            for (var i = 0 ; i < len - 1; i++) {
                arr.push([a[i].lng, a[i].lat]);
            }
            this.overlaysCache = arr;
        }

        //判断一个标注点是否在多边形里
        //pt标注点，poly多边形数组
        function isInsidePolygon(pt, poly) {
            for (var c = false, i = -1, l = poly.length, j = l - 1; ++i < l; j = i)
                ((poly[i].lat <= pt.lat && pt.lat < poly[j].lat) || (poly[j].lat <= pt.lat && pt.lat < poly[i].lat)) &&
                (pt.lng < (poly[j].lng - poly[i].lng) * (pt.lat - poly[i].lat) / (poly[j].lat - poly[i].lat) + poly[i].lng) &&
                (c = !c);
            return c;
        }
    </script>
</body>
</html>

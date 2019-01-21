import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_cnode/api/request.dart' as Request;

var api = new Request.Api();

class CreateTopic extends StatefulWidget {
  CreateTopic({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CreateTopicState();
}

class _CreateTopicState extends State<CreateTopic> {
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _tabEditingController = TextEditingController();
  FocusNode _tabFocusNode = FocusNode();
  TextEditingController _titleEditingController = TextEditingController();
  TextEditingController _contentEditingController = TextEditingController();
  String _tabError = null;
  String _tab;
  List _tabList = [
    {'value': 'share', 'name': '分享'},
    {'value': 'ask', 'name': '问答'},
    {'value': 'dev', 'name': '测试'},
  ];
  showSnackBar(String text) {
    var snackbar =
        SnackBar(content: Text(text), duration: Duration(seconds: 2));
    _scaffoldkey.currentState.showSnackBar(snackbar);
  }

  showPicker() {
    print('tabList $_tabList ');
    _tabFocusNode.unfocus();
    var pickerdata = _tabList.map((tab) => tab['name']);
    Picker picker = new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: pickerdata.toList()),
        cancelText: '取消',
        confirmText: '确认',
        changeToFirst: true,
        textAlign: TextAlign.left,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          _tab = _tabList[value[0]]['value'];
          _tabEditingController.text = picker.getSelectedValues()[0];
        });
    picker.showModal(this.context);
  }

  publish() async {
    var _form = _formKey.currentState;
    if (_tab == null || _tab == '') {
      setState(() {
        _tabError = '话题类型不能为空';
      });
      return;
    } else {
      setState(() {
        _tabError = null;
      });
    }
    if (_form.validate()) {
      _form.save();
      print('tab $_tab ');
      try {
        var ret = await api.dio.post('/topics', data: {
          'title': _titleEditingController.text,
          'tab': _tab,
          'content': _contentEditingController.text,
        });
        _titleEditingController.text = '';
        _contentEditingController.text = '';
        _tabEditingController.text = '';
        _tab = null;
        print('publish ret $ret');
        this.showSnackBar('发布成功');
      } catch (e) {
        this.showSnackBar(e.response.data['error_msg']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
          title: Text('发布话题'),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              child: Text('发布'),
              onPressed: this.publish,
            )
          ],
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[Text('取消')],
              ))),
      body: Container(
        // padding: EdgeInsets.all(10),
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextField(
                  focusNode: _tabFocusNode,
                  keyboardType: null,
                  enableInteractiveSelection: false,
                  decoration: InputDecoration(
                      hintText: '选择话题', labelText: '话题', errorText: _tabError),
                  controller: _tabEditingController,
                  enabled: true,
                  onTap: this.showPicker,
                ),
                TextFormField(
                  enableInteractiveSelection: false,
                  decoration: InputDecoration(
                    hintText: '请输入标题',
                    labelText: '标题',
                  ),
                  validator: (val) {
                    if (val == null || val == '') {
                      return '标题不能为空';
                    }
                  },
                  controller: _titleEditingController,
                ),
                TextFormField(
                  maxLines: 10,
                  enableInteractiveSelection: false,
                  decoration: InputDecoration(
                    hintText: '请输入内容',
                    labelText: '内容',
                  ),
                  validator: (val) {
                    if (val == null || val == '') {
                      return '内容不能为空';
                    }
                  },
                  controller: _contentEditingController,
                ),
              ],
            )),
      ),
    );
  }
}

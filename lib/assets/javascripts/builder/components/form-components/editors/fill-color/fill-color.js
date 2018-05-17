var _ = require('underscore');
var Backbone = require('backbone');
var EditorHelpers = require('builder/components/form-components/editors/editor-helpers-extend');

var FillColorSolidView = require('builder/components/form-components/editors/fill-color/fill-color-solid-view');
var FillColorByValueView = require('builder/components/form-components/editors/fill-color/fill-color-by-value-view');

var tabPaneTemplate = require('builder/components/tab-pane/tab-pane.tpl');
var createRadioLabelsTabPane = require('builder/components/tab-pane/create-radio-labels-tab-pane');

var SOLID = 'solid';
var BY_VALUE = 'value';

Backbone.Form.editors.FillColor = Backbone.Form.editors.Base.extend({
  className: 'Form-InputFillColor',

  initialize: function (options) {
    Backbone.Form.editors.Base.prototype.initialize.call(this, options);
    EditorHelpers.setOptions(this, options);

    if (this.options.editorAttrs) {
      this.options = _.extend(this.options, {
        columns: this.options.options,
        query: this.options.query,
        configModel: this.options.configModel,
        userModel: this.options.userModel,
        editorAttrs: this.options.editorAttrs,
        imageEnabled: this.options.editorAttrs.imageEnabled,
        modals: this.options.modals
      });

      var editorAttrs = this.options.editorAttrs;

      if (editorAttrs.hidePanes) {
        this._hidePanes = editorAttrs.hidePanes;

        if (!_.contains(this._hidePanes, 'value')) {
          if (!options.configModel) throw new Error('configModel param is required');
          if (!options.userModel) throw new Error('userModel param is required');
          if (!options.modals) throw new Error('modals param is required');
          if (!options.query) throw new Error('query param is required');
        }
      }

      if (editorAttrs.categorizeColumns) {
        this._categorizeColumns = true;
      }
    }

    this._dialogMode = this.options.dialogMode || 'nested';
    this._initViews();
  },

  _initViews: function () {
    var self = this;

    var solidPane = {
      name: SOLID,
      label: _t('form-components.editors.fill.input-number.' + SOLID),
      createContentView: function () {
        return self._generateSolidContentView();
      }
    };

    var valuePane = {
      name: BY_VALUE,
      label: _t('form-components.editors.fill.input-number.' + BY_VALUE),
      createContentView: function () {
        return self._generateValueContentView();
      }
    };

    this._tabPaneTabs = [];

    if (this.options.editorAttrs && this.options.editorAttrs.hidePanes) {
      var hidePanes = this.options.editorAttrs.hidePanes;
      if (!_.contains(hidePanes, SOLID)) {
        this._tabPaneTabs.push(solidPane);
      }
      if (!_.contains(hidePanes, BY_VALUE)) {
        this._tabPaneTabs.push(valuePane);
      }
    } else {
      this._tabPaneTabs = [solidPane, valuePane];
    }

    var tabPaneOptions = {
      tabPaneOptions: {
        template: tabPaneTemplate,
        tabPaneItemOptions: {
          tagName: 'li',
          klassName: 'CDB-NavMenu-item'
        }
      },
      tabPaneItemLabelOptions: {
        tagName: 'div',
        className: 'CDB-Text CDB-Size-medium'
      }
    };

    var selectedTabPaneIndex = this._getSelectedTabPaneIndex();
    this._tabPaneTabs[selectedTabPaneIndex].selected = true;

    this._tabPaneView = createRadioLabelsTabPane(this._tabPaneTabs, tabPaneOptions);
    this.$el.append(this._tabPaneView.render().$el);
  },

  _getSelectedTabPaneIndex: function () {
    var SOLID_TAB_PANE = 0;
    var BY_VALUE_TAB_PANE = 1;

    return this.model.get('fillColor').range &&
      this._tabPaneTabs.length > 1
      ? BY_VALUE_TAB_PANE
      : SOLID_TAB_PANE;
  },

  _removeFillColorSolidDialog: function () {
    this._fillColorSolidView.removeDialog();
  },

  _removeFillColorByValueDialog: function () {
    this._fillColorByValueView.removeDialog();
  },

  _generateSolidContentView: function () {
    var colorAttributes = _.clone(this.model.get(this.key));

    this._fillColorSolidView = new FillColorSolidView({
      model: this.model,
      columns: this.options.columns,
      query: this.options.query,
      configModel: this.options.configModel,
      userModel: this.options.userModel,
      editorAttrs: this.options.editorAttrs,
      modals: this.options.modals,
      dialogMode: this.options.dialogMode,
      colorAttributes: colorAttributes,
      popupConfig: {
        cid: this.cid,
        $el: this.$el
      }
    });

    this.applyESCBind(this._removeFillColorSolidDialog);
    this.applyClickOutsideBind(this._removeFillColorSolidDialog);

    this._fillColorSolidView.on('onInputChanged', function (input) {
      this.trigger('change', input);
    }, this);

    return this._fillColorSolidView;
  },

  _generateValueContentView: function () {
    var colorAttributes = _.clone(this.model.get(this.key));

    this._fillColorByValueView = new FillColorByValueView({
      columns: this.options.columns,
      query: this.options.query,
      configModel: this.options.configModel,
      userModel: this.options.userModel,
      editorAttrs: this.options.editorAttrs,
      model: this.model,
      dialogMode: this.options.dialogMode,
      colorAttributes: colorAttributes,
      categorizeColumns: this.options.categorizeColumns,
      imageEnabled: this.options.imageEnabled,
      modals: this.options.modals,
      hideTabs: this.options.hideTabs,
      popupConfig: {
        cid: this.cid,
        $el: this.$el
      }
    });

    this.applyESCBind(this._removeFillColorByValueDialog);
    this.applyClickOutsideBind(this._removeFillColorByValueDialog);

    this._fillColorByValueView.on('onInputChanged', function (input) {
      this.trigger('change', input);
    }, this);

    return this._fillColorByValueView;
  },

  getValue: function (param) {
    var selectedTabPaneName = this._tabPaneView.getSelectedTabPaneName();

    return selectedTabPaneName === SOLID && this._fillColorSolidView
      ? this._getFillSolidValues()
      : this._getFillByValueValues();
  },

  _getFillSolidValues: function () {
    var collection = this._fillColorSolidView._inputCollection;
    var colorModel = collection.findWhere({ type: 'color' });
    var imageModel = collection.findWhere({ type: 'image' });

    var colorOmmitAttributes = [
      'createContentView',
      'selected',
      'type',
      'image',
      'marker',
      'range'
    ];

    var imageOmmitAttributes = [
      'createContentView',
      'selected',
      'type',
      'fixed',
      'range'
    ];

    var colorAttributes = _.omit(colorModel.attributes, colorOmmitAttributes);
    var imageAttributes = _.omit(imageModel.attributes, imageOmmitAttributes);
    var values = _.extend({}, imageAttributes, colorAttributes);

    colorModel.set(values);
    imageModel.set(values);

    return values;
  },

  _getFillByValueValues: function () {
    var collection = this._fillColorByValueView._inputCollection;
    var colorModel = collection.findWhere({ type: 'color' });

    var colorOmmitAttributes = [
      'createContentView',
      'selected',
      'type'
    ];

    var values = _.omit(colorModel.attributes, colorOmmitAttributes);

    colorModel.set(values);

    return values;
  }
});
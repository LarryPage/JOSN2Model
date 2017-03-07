//
//  ViewController.swift
//  JOSN2Model
//
//  Created by LiXiangCheng on 16/10/7.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSUserNotificationCenterDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate, NSMenuDelegate {
    
    //Shows the list of files' preview
    @IBOutlet weak var tableView: NSTableView!
    
    //Connected to the top right corner to show the current parsing status
    @IBOutlet weak var statusTextField: NSTextField!
    
    //Connected to the multiFile check button
    @IBOutlet weak var multiFileCheckButton: NSButton!
    
    //Connected to the save button
    @IBOutlet weak var saveButton: NSButton!
    
    //Connected to the JSON input text view
    @IBOutlet var httpParamText: NSTextView!
    
    //Connected to the scroll view which wraps the httpParamText
    @IBOutlet weak var httpParamScrollView: NSScrollView!
    
    //Connected to the JSON input text view
    @IBOutlet var sourceText: NSTextView!
    @IBOutlet var jsonInputTopConstraint: NSLayoutConstraint!
    
    //Connected to the scroll view which wraps the sourceText
    @IBOutlet weak var scrollView: NSScrollView!
    
    //Connected to Constructors check box
    @IBOutlet weak var generateConstructors: NSButtonCell!
    
    //Connected to Utility Methods check box
    @IBOutlet weak var generateUtilityMethods: NSButtonCell!
    
    //Connected to root class name field
    @IBOutlet weak var classNameField: NSTextFieldCell!
    
    //Connected to parent class name field
    @IBOutlet weak var parentClassName: NSTextField!
    
    //Connected to class prefix field
    @IBOutlet weak var classPrefixField: NSTextField!
    
    //Connected to the first line statement field
    @IBOutlet weak var firstLineField: NSTextField!
    
    //Connected to the languages pop up
    @IBOutlet weak var languagesPopup: NSPopUpButton!
    
    //Connected to the http request method
    @IBOutlet weak var httpMethodPopup: NSPopUpButton!
    
    //Connected to the http request Url string field
    @IBOutlet weak var httpUrlField: NSTextField!
    
    //Connected to the http request send button
    @IBOutlet weak var sendButton: NSButton!
    
    var jsonWriter: SBJson4Writer?
    
    //Holds the currently selected language
    var selectedLang : LangModel!
    
    //Returns the title of the selected language in the languagesPopup
    var selectedLanguageName : String
    {
        return languagesPopup.titleOfSelectedItem!
    }
    
    //Should hold list of supported languages, where the key is the language name and the value is LangModel instance
    var langs : [String : LangModel] = [String : LangModel]()
    
    //Holds list of the generated files
    var files : [FileRepresenter] = [FileRepresenter]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        loadSupportedLanguages()
        setupNumberedTextView()
        initSBJsonWriter()
        setLanguagesSelection()
        updateUIFieldsForSelectedLanguage()
        
        setHttpMethodSelection()
        setupNumberedhttpParamScrollView()
        
        self.httpParamText.isAutomaticQuoteSubstitutionEnabled=false
        self.httpParamText.isAutomaticDashSubstitutionEnabled=false
        self.sourceText.isAutomaticQuoteSubstitutionEnabled=false
        self.sourceText.isAutomaticDashSubstitutionEnabled=false
    }
    
    /**
     Sets the values of httpMethodPopup items' titles
     */
    func setHttpMethodSelection()
    {
        let methods = ["GET","POST","HEAD","PUT","DELETE"]
        httpMethodPopup.removeAllItems()
        httpMethodPopup.addItems(withTitles: methods)
        httpMethodPopup.menu?.delegate=self
        jsonInputTopConstraint.constant=28;
    }
    
    func menuDidClose(_ menu: NSMenu)
    {
        if(menu == httpMethodPopup.menu)
        {
            switch httpMethodPopup.titleOfSelectedItem! {
            case "GET","HEAD":
                jsonInputTopConstraint.constant=28;
                httpParamText.string = ""
            case "POST","PUT","DELETE":
                jsonInputTopConstraint.constant=130;
                var parameters = [String: String]()
                parameters["param1"] = "value1"
                parameters["param2"] = "value2"
                let data = self.jsonWriter!.data(with: parameters)
                let output = String(data: data!, encoding: String.Encoding.utf8)
                httpParamText.string = output
            default:
                jsonInputTopConstraint.constant=28;
                httpParamText.string = ""
            }
            sourceText.string = ""
            generateClasses()
        }
    }
    
    /**
     Sets the needed configurations for show the line numbers in the input text view
     */
    func setupNumberedhttpParamScrollView()
    {
        let lineNumberView = NoodleLineNumberView(scrollView: httpParamScrollView)
        httpParamScrollView.hasHorizontalRuler = false
        httpParamScrollView.hasVerticalRuler = true
        httpParamScrollView.verticalRulerView = lineNumberView
        httpParamScrollView.rulersVisible = true
        httpParamText.font = NSFont.userFixedPitchFont(ofSize: NSFont.smallSystemFontSize())
        
    }
    
    //MARK: - send http request
    @IBAction func sendBtn(_ sender: AnyObject)
    {
        //处理url
        var string = httpUrlField.stringValue
        if string.characters.count == 0{
            self.showErrorStatus("It seems your url is not valid!")
            return;
        }
        
        var urlStr = string;
        var parameters = [String: String]()
        let urlComponents = NSURLComponents(string: string)
        let queryItems = urlComponents?.queryItems
        if (queryItems != nil) {
            for item in queryItems! {
                parameters[item.name] = item.value!
            }
            //print(urlComponents!.query!)
            let rangIndex = string.range(of: "?")
            urlStr = string.substring(to: rangIndex!.lowerBound)
        }
        
        //处理param
        var str = httpParamText.string!
        str = jsonStringByRemovingUnwantedCharacters(str)
        if str.characters.count>0 {
            if let data = str.data(using: String.Encoding.utf8){
                do {
                    let jsonData : Any = try JSONSerialization.jsonObject(with: data, options: [])
                    var json : NSDictionary!
                    if jsonData is NSDictionary{
                        //fine nothing to do
                        json = jsonData as! NSDictionary
                    }else{
                        json = unionDictionaryFromArrayElements(jsonData as! NSArray)
                    }
                    
                    for (key, value) in json {
                        parameters["\(key)"] = "\(value)"
                    }
                } catch {
                    self.showErrorStatus("It seems your param is not valid!")
                    return;
                }
            }
        }
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet().adding("application/json")
        switch httpMethodPopup.titleOfSelectedItem! {
        case "GET":
            manager.get(urlStr, parameters: parameters, success: { (operation, responseData) -> Void in
                if responseData is NSDictionary {
                    print(responseData)
                    let data = self.jsonWriter!.data(with: responseData)
                    let output = String(data: data!, encoding: String.Encoding.utf8)
                    self.sourceText.string = output
                    self.generateClasses()
                } else {
                    self.showErrorStatus("error: responseData is not a dictionary json");
                    print("error: responseData is not a dictionary json")
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                self.showErrorStatus(error.localizedDescription)
            })
        case "POST":
            manager.post(urlStr, parameters: parameters, success: { (operation, responseData) -> Void in
                if responseData is NSDictionary {
                    print(responseData)
                    let data = self.jsonWriter!.data(with: responseData)
                    let output = String(data: data!, encoding: String.Encoding.utf8)
                    self.sourceText.string = output
                    self.generateClasses()
                } else {
                    self.showErrorStatus("error: responseData is not a dictionary json");
                    print("error: responseData is not a dictionary json")
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                self.showErrorStatus(error.localizedDescription)
            })
        case "HEAD":
            manager.head(urlStr, parameters: parameters, success: { (operation) -> Void in
                self.showSuccessStatus("HEAD url done");
            }, failure: { (operation, error) -> Void in
                print(error)
                self.showErrorStatus(error.localizedDescription)
            })
        case "PUT":
            manager.put(urlStr, parameters: parameters, success: { (operation, responseData) -> Void in
                if responseData is NSDictionary {
                    print(responseData)
                    let data = self.jsonWriter!.data(with: responseData)
                    let output = String(data: data!, encoding: String.Encoding.utf8)
                    self.sourceText.string = output
                    self.generateClasses()
                } else {
                    self.showErrorStatus("error: responseData is not a dictionary json");
                    print("error: responseData is not a dictionary json")
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                self.showErrorStatus(error.localizedDescription)
            })
        case "DELETE":
            manager.delete(urlStr, parameters: parameters, success: { (operation, responseData) -> Void in
                if responseData is NSDictionary {
                    print(responseData)
                    let data = self.jsonWriter!.data(with: responseData)
                    let output = String(data: data!, encoding: String.Encoding.utf8)
                    self.sourceText.string = output
                    self.generateClasses()
                } else {
                    self.showErrorStatus("error: responseData is not a dictionary json");
                    print("error: responseData is not a dictionary json")
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                self.showErrorStatus(error.localizedDescription)
            })
        default:
            manager.post(urlStr, parameters: parameters, success: { (operation, responseData) -> Void in
                if responseData is NSDictionary {
                    print(responseData)
                    let data = self.jsonWriter!.data(with: responseData)
                    let output = String(data: data!, encoding: String.Encoding.utf8)
                    self.sourceText.string = output
                    self.generateClasses()
                } else {
                    self.showErrorStatus("error: responseData is not a dictionary json");
                    print("error: responseData is not a dictionary json")
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                self.showErrorStatus(error.localizedDescription)
            })
        }
        
        
    }
    
    /**
     Sets the values of languagesPopup items' titles
     */
    func setLanguagesSelection()
    {
        let langNames = Array(langs.keys).sorted()
        languagesPopup.removeAllItems()
        languagesPopup.addItems(withTitles: langNames)
        
    }
    
    /**
     Sets the needed configurations for show the line numbers in the input text view
     */
    func setupNumberedTextView()
    {
        let lineNumberView = NoodleLineNumberView(scrollView: scrollView)
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler = true
        scrollView.verticalRulerView = lineNumberView
        scrollView.rulersVisible = true
        sourceText.font = NSFont.userFixedPitchFont(ofSize: NSFont.smallSystemFontSize())
        
    }
    
    /**
     Updates the visible fields according to the selected language
     */
    func updateUIFieldsForSelectedLanguage()
    {
        loadSelectedLanguageModel()
        if selectedLang.supportsFirstLineStatement != nil && selectedLang.supportsFirstLineStatement!{
            firstLineField.isHidden = false
            firstLineField.placeholderString = selectedLang.firstLineHint
        }else{
            firstLineField.isHidden = true
        }
        
        if selectedLang.modelDefinitionWithParent != nil || selectedLang.headerFileData?.modelDefinitionWithParent != nil{
            parentClassName.isHidden = false
        }else{
            parentClassName.isHidden = true
        }
    }
    
    
    
    //MARK: - Handling pre defined languages
    func loadSupportedLanguages()
    {
        if let langFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) as [URL]!{
            for langFile in langFiles{
                if let data = try? Data(contentsOf: langFile), let langDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? NSDictionary{
                    let lang = LangModel(fromDictionary: langDictionary)
                    if langs[lang.displayLangName] != nil{
                        continue
                    }
                    langs[lang.displayLangName] = lang
                }
                
                
            }
        }
        
    }
    
    // MARK: - Init the SBJsonWriter
    func initSBJsonWriter()
    {
        jsonWriter = SBJson4Writer()
        jsonWriter!.humanReadable = true
        jsonWriter!.sortKeys = true
    }
    
    
    // MARK: - parse the json file
    func parseJSONData(jsonData: Data!)
    {
        let parser : SBJson4Parser = SBJson4Parser.parser({ (object, ignored) in
            let data = self.jsonWriter!.data(with: object)
            let output = String(data: data!, encoding: String.Encoding.utf8)
            self.sourceText.string = output
            self.generateClasses()
        }, allowMultiRoot: false, unwrapRootArray: false) { errorBlock in
            //                self.showError(errorBlock)
            } as! SBJson4Parser
        
        parser.parse(jsonData)
    }
    
    //MARK: - Handlind events
    
    @IBAction func openJSONFiles(sender: AnyObject)
    {
        let oPanel: NSOpenPanel = NSOpenPanel()
        oPanel.canChooseDirectories = false
        oPanel.canChooseFiles = true
        oPanel.allowsMultipleSelection = false
        oPanel.allowedFileTypes = ["json","JSON"]
        oPanel.prompt = "Choose JSON file"
        
        oPanel.beginSheetModal(for: self.view.window!, completionHandler: { (button : Int) -> Void in
            if button == NSFileHandlingPanelOKButton{
                
                let jsonPath = oPanel.urls.first!.path
                let fileHandle = FileHandle(forReadingAtPath: jsonPath)
                
                self.parseJSONData(jsonData: (fileHandle!.readDataToEndOfFile() as NSData!) as Data!)
                
            }
        })
    }
    
    @IBAction func toggleMultiFileCheckButton(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    @IBAction func toggleConstructors(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    
    @IBAction func toggleUtilities(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    @IBAction func rootClassNameChanged(_ sender: AnyObject) {
        generateClasses()
    }
    
    @IBAction func parentClassNameChanged(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    
    @IBAction func classPrefixChanged(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    
    @IBAction func selectedLanguageChanged(_ sender: AnyObject)
    {
        updateUIFieldsForSelectedLanguage()
        generateClasses();
    }
    
    
    @IBAction func firstLineChanged(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    //MARK: - NSTextDelegate
    
    func textDidChange(_ notification: Notification) {
        generateClasses()
    }
    
    
    //MARK: - Language selection handling
    func loadSelectedLanguageModel()
    {
        selectedLang = langs[selectedLanguageName]
        
    }
    
    
    //MARK: - NSUserNotificationCenterDelegate
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool
    {
        return true
    }
    
    
    //MARK: - Showing the open panel and save files
    @IBAction func saveFiles(_ sender: AnyObject)
    {
        let openPanel = NSOpenPanel()
        openPanel.allowsOtherFileTypes = false
        openPanel.treatsFilePackagesAsDirectories = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Choose"
        openPanel.beginSheetModal(for: self.view.window!, completionHandler: { (button : Int) -> Void in
            if button == NSFileHandlingPanelOKButton{
                
                self.saveToPath(openPanel.url!.path)
                
                self.showDoneSuccessfully()
            }
        })
    }
    
    
    /**
     Saves all the generated files in the specified path
     
     - parameter path: in which to save the files
     */
    func saveToPath(_ path : String)
    {
        var error : NSError?
        if self.multiFileCheckButton.state==NSOnState {//多个model文件
            for file in files{
                let fileContent = file.toString()
                var fileExtension = selectedLang.fileExtension
                if file is HeaderFileRepresenter{
                    fileExtension = selectedLang.headerFileData.headerFileExtension
                }
                let filePath = "\(path)/\(file.className).\(fileExtension)"
                
                do {
                    try fileContent.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil{
                    showError(error!)
                    break
                }
            }
        }
        else{
            for index in 0...1 {
                let curFile = files[index]
                var fileContent = ""
                if curFile is HeaderFileRepresenter{
                    for file in files{
                        if file is HeaderFileRepresenter{
                            fileContent = file.toStr() + fileContent
                        }
                    }
                }
                else{
                    for file in files{
                        if file is HeaderFileRepresenter{
                        }
                        else{
                            fileContent = file.toStr() + fileContent
                        }
                    }
                }
                fileContent = curFile.toHeadStr() + fileContent
                var fileExtension = selectedLang.fileExtension
                if curFile is HeaderFileRepresenter{
                    fileExtension = selectedLang.headerFileData.headerFileExtension
                }
                let filePath = "\(path)/\(curFile.className).\(fileExtension)"
                
                do {
                    try fileContent.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil{
                    showError(error!)
                    break
                }
            }
        }
    }
    
    
    //MARK: - Messages
    /**
     Shows the top right notification. Call it after saving the files successfully
     */
    func showDoneSuccessfully()
    {
        let notification = NSUserNotification()
        notification.title = "Success!"
        notification.informativeText = "Your \(selectedLang.langName) model files have been generated successfully."
        notification.deliveryDate = Date()
        
        let center = NSUserNotificationCenter.default
        center.delegate = self
        center.deliver(notification)
    }
    
    /**
     Shows an NSAlert for the passed error
     */
    func showError(_ error: NSError!)
    {
        if error == nil{
            return;
        }
        let alert = NSAlert(error: error)
        alert.runModal()
    }
    
    /**
     Shows the passed error status message
     */
    func showErrorStatus(_ errorMessage: String)
    {
        
        statusTextField.textColor = NSColor.red
        statusTextField.stringValue = errorMessage
    }
    
    /**
     Shows the passed success status message
     */
    func showSuccessStatus(_ successMessage: String)
    {
        
        statusTextField.textColor = NSColor.green
        statusTextField.stringValue = successMessage
    }
    
    
    
    //MARK: - Generate files content
    /**
     Validates the sourceText string input, and takes any needed action to generate the model classes and view them in the preview panel
     */
    func generateClasses()
    {
        saveButton.isEnabled = false
        var str = sourceText.string!
        
        if str.characters.count == 0{
            //Nothing to do, just clear any generated files
            files.removeAll(keepingCapacity: false)
            tableView.reloadData()
            return;
        }
        var rootClassName = classNameField.stringValue
        if rootClassName.characters.count == 0{
            rootClassName = "RootClass"
        }
        sourceText.isEditable = false
        //Do the lengthy process in background, it takes time with more complicated JSONs
        runOnBackground {
            str = jsonStringByRemovingUnwantedCharacters(str)
            if let data = str.data(using: String.Encoding.utf8){
                var error : NSError?
                do {
                    let jsonData : Any = try JSONSerialization.jsonObject(with: data, options: [])
                    var json : NSDictionary!
                    if jsonData is NSDictionary{
                        //fine nothing to do
                        json = jsonData as! NSDictionary
                    }else{
                        json = unionDictionaryFromArrayElements(jsonData as! NSArray)
                    }
                    self.loadSelectedLanguageModel()
                    self.files.removeAll(keepingCapacity: false)
                    let fileGenerator = self.prepareAndGetFilesBuilder()
                    fileGenerator.addFileWithName(&rootClassName, jsonObject: json, files: &self.files)
                    fileGenerator.fixReferenceMismatches(inFiles: self.files)
                    self.files = Array(self.files.reversed())
                    runOnUiThread{
                        self.sourceText.isEditable = true
                        self.showSuccessStatus("Valid JSON structure")
                        self.saveButton.isEnabled = true
                        
                        self.tableView.reloadData()
                    }
                } catch let error1 as NSError {
                    error = error1
                    runOnUiThread({ () -> Void in
                        self.sourceText.isEditable = true
                        self.saveButton.isEnabled = false
                        if error != nil{
                            print(error!)
                        }
                        self.showErrorStatus("It seems your JSON object is not valid!")
                    })
                    
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    /**
     Creates and returns an instance of FilesContentBuilder. It also configure the values from the UI components to the instance. I.e includeConstructors
     
     - returns: instance of configured FilesContentBuilder
     */
    func prepareAndGetFilesBuilder() -> FilesContentBuilder
    {
        let filesBuilder = FilesContentBuilder.instance
        filesBuilder.includeConstructors = (generateConstructors.state == NSOnState)
        filesBuilder.includeUtilities = (generateUtilityMethods.state == NSOnState)
        filesBuilder.firstLine = firstLineField.stringValue
        filesBuilder.lang = selectedLang!
        filesBuilder.classPrefix = classPrefixField.stringValue
        filesBuilder.parentClassName = parentClassName.stringValue
        return filesBuilder
    }
    
    
    
    
    //MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        if self.multiFileCheckButton.state==NSOnState {//多个model文件
            return files.count
        }
        else{//一个model文件
            return files.count>0 ? 2 : 0
        }
    }
    
    
    //MARK: - NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.make(withIdentifier: "fileCell", owner: self) as! FilePreviewCell
        if self.multiFileCheckButton.state==NSOnState {//多个model文件
            let file = files[row]
            cell.file = file
        }
        else{//一个model文件
            cell.setFile(files, index: row)
        }
        
        return cell
    }
    
    
    
}


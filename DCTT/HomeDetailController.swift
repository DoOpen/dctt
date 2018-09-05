//
//  HomeDetailController.swift
//  DCTT
//
//  Created by gener on 17/11/21.
//  Copyright © 2017年 Light.W. All rights reserved.
//

import UIKit
import Kingfisher

class HomeDetailController: BaseDetailController{

    var data:[String:Any]!
    
    private var imgArr = [String]()
    private var _titleView:UIView!
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _tableview.register(UINib (nibName: "HomeDetailImgCell3", bundle: nil), forCellReuseIdentifier: "HomeDetailImgCell3Identifier")
        
        //titleview
        _titleView = titleView()
        _titleView.isHidden = true
        navigationItem.titleView = _titleView

        /////TTPostCommentSuccessNotification
        NotificationCenter.default.addObserver(self, selector: #selector(postCommentSuccessAction(_ :)), name: TTPostCommentSuccessNotification, object: nil)
        
        fillData()
        loadComment()
    }

    func postCommentSuccessAction(_ noti:NSNotification) {
        loadComment()
    }
    
    
    //HeadView
    func fillData()  {
        headView.fill(data)
        headView.avatarClickedAction = {[weak self] in
            guard let ss = self else { return}
            
            let vc = MeHomePageController.init(style:.plain)
            if let uid = ss.data["uid"] as? String {
                vc.uid = uid
            }
            
            ss.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        let images = String.isNullOrEmpty(data["images"])
        if images.lengthOfBytes(using: String.Encoding.utf8) > 50 {
           let arr = images.components(separatedBy: ",")
            if arr.count > 0 {
                imgArr = imgArr + arr
            }
        }
        

    }
    

    
    

    //MARK: -
    func titleView() -> UIView {
        let _bgview = UIView (frame: CGRect (x: 0, y: 0, width: 30, height: 30))

        let icon = UIImageView (frame: CGRect (x: 0, y: 0, width: _bgview.frame.height, height: _bgview.frame.height))
        icon.image = UIImage (named: "avatar_default")
        icon.layer.cornerRadius = _bgview.frame.height / 2
        icon.layer.masksToBounds = true
        _bgview.addSubview(icon)
        
        //icon
        if let dic = data["user"] as? [String:Any]{
            if let igurl = dic["avatar"] as? String {
                let url = URL.init(string: igurl)
                icon.kf.setImage(with: url, placeholder: UIImage (named: "avatar_default"), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }

        
        //....
        let btn = UIButton (frame: CGRect (x: icon.frame.maxX + 10, y: 0, width: 60, height: 25))
        btn.backgroundColor = UIColor (red: 17/255.0, green: 135/255.0, blue: 212/255.0, alpha: 1)
        btn.setTitle("关注", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(watchBtnAction), for: .touchUpInside)
        //_bgview.addSubview(btn)
        
        return _bgview
    }
    
    func watchBtnAction() {
        //关注
        
    }
    
    
    //MARK: - 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _titleView.isHidden = !(scrollView.contentOffset.y > 60)
    }
    
    
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 +  lroundf(ceilf(Float(imgArr.count) / 3.0) ) // + pic 个数
        }else{
        
            return commentDataArr.count //评论数
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCellReuseIdentifier", for: indexPath)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let _text = String.isNullOrEmpty(data["content"])
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textColor = UIColor.black
                
                let paragraphStyle = NSMutableParagraphStyle.init()
                paragraphStyle.lineSpacing = 5
                paragraphStyle.lineBreakMode = .byCharWrapping
                paragraphStyle.firstLineHeadIndent = 30
                
                let dic:[String:Any] = [NSFontAttributeName:UIFont.systemFont(ofSize: 17) , NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:1]
                let attriStr = NSAttributedString.init(string: _text, attributes: dic)
                cell.textLabel?.attributedText = attriStr
            }else{//带有图的cell
                cell = tableView.dequeueReusableCell(withIdentifier: "HomeDetailImgCell3Identifier", for: indexPath) as! HomeDetailImgCell3

                /////
                let row = indexPath.row - 1
                let igs = imagesWithIndex(row)
                (cell as! HomeDetailImgCell3).tapActionHandler = {[weak self] i in
                    if  let ss = self {
                        let index = row * 3 + i
                        let vc  = TTImagePreviewController2()
                        vc.index = index - 1
                        vc.dataArry = ss.imgArr
                        
                        ss.navigationController?.present(vc, animated: false, completion: nil)
                    }
                    
                }
                
                (cell as! HomeDetailImgCell3).fill(igs)

            }
        }else{
             cell = tableView.dequeueReusableCell(withIdentifier: "HomeDetailCommentCellIdentifier", for: indexPath)
            let d = commentDataArr[indexPath.row]
            (cell as! HomeDetailCommentCell).fill(d)
            (cell as! HomeDetailCommentCell).avatarClickedAction = {[weak self] in
                guard let ss = self else {return}
                
                let vc = MeHomePageController.init(style:.plain)
                if let uid = d["uid"] as? String {
                    vc.uid = uid
                }
                
                ss.navigationController?.pushViewController(vc, animated: true)
            }
        }
        

        cell.selectionStyle = .none
        
        return cell
    }
    
    deinit {
        print("HomeDetailController deinit")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
    }
    

    //MARK: -
    func imagesWithIndex(_ index:Int) -> [String] {
        var arr = [String]()
        for i in index * 3 ..< imgArr.count{
            let origin = imgArr[i]
            arr.append(origin)
            if arr.count >= 3 {
                break
            }
        }
        
        return arr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}

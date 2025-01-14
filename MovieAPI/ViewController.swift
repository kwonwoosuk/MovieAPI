//
//  ViewController.swift
//  MovieAPI
//
//  Created by 권우석 on 1/14/25.
//

import UIKit
import Alamofire
import SnapKit


struct BoxOfficeList: Decodable {
    let boxOfficeResult: BoxOfficeResult
}

struct BoxOfficeResult: Decodable {
    let dailyBoxOfficeList: [Movie]
}

struct Movie: Decodable { //
    let rank: String // 순위비교하려면...그냥 순서대로 출력하면 되것구나야
    let movieNm: String
    let openDt: String
}

class ViewController: UIViewController {
    
    /*
     생성한 프로젝트(코드베이스 학습 과제)에 연이어서 복습을 진행
     - 영화진흥위원회 API를 통해 어제 날짜 기준으로 일간 박스오피스 정보를 보여
     주는 예제입니다.
     - 첫 빌드 시 어제 날짜를 보여주고, 텍스트필드에 yyyyMMdd 형식으로 검색을
     통해 원하는 날짜에 해당하는 박스오피스 정보를
     조회해봅니다.
     [Easy]
     -
     뷰컨트롤러에 레이블 9개를 얹이고, 1위부터 3위에 해당하는 영화를 “순위, 영
     화 제목, 개봉일” 3가지를 표현해줍니다.
     rank순위
     movieNm 제목
     openDt 개봉일
     [순위0][제목0][개봉일0]
     [순위1][제목1][개봉일^^]
     [순위2][제목2][개봉2]
     http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=07918ad2a80648eb7bd0d5fb50437098&targetDt=20120101
     
     
     요청 방식 Get방식으로 호출
     targetDt를 yyyyMMdd로 입력받아서 넣으면 될것같디
     BoxOfficeResult안에 있는 movie안에 있는 데이터... 꽁꽁숨겨놓으셨세여
     */
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "film_image")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
     let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "    날짜를 입력하세요 (yyyyMMdd)"
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .white
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("검색", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        return button
    }()
    
    var rankLabels: [UILabel] = []
    var titleLabels: [UILabel] = []
    var dateLabels: [UILabel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        setupUI()
        configureLayout()
        showYesterdayRank()
    }
    func setupUI() {
        
        [backgroundImageView, searchTextField, searchButton].forEach { view.addSubview($0) }
        
        for _ in 0..<9 {
            if rankLabels.count < 3 {
                let label = rankLabel()  // rankLabel 스타일 적용
                rankLabels.append(label)
                view.addSubview(label)
            } else if titleLabels.count < 3 {
                let label = basicLabel()  // 기본 스타일
                titleLabels.append(label)
                view.addSubview(label)
            } else {
                let label = basicLabel()  // 기본 스타일
                dateLabels.append(label)
                view.addSubview(label)
            }
        }
        
    }
    
    func rankLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center // 따로따로 적용시키려면 rank레이블에만 테두리 주고싶
        label.backgroundColor = .white
        return label
    }
    
    func basicLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        return label
    }
    
     func configureLayout() {
        backgroundImageView.snp.makeConstraints { make in // $0 치는거보다 make가 더 빠른거 같다
            make.edges.equalToSuperview()
        }
        
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view).offset(20)
            make.width.equalTo(view).multipliedBy(0.7) // view의 70센트 비율로
            make.height.equalTo(40)
        }
        
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(searchTextField)
            make.leading.equalTo(searchTextField.snp.trailing).offset(10)
            make.trailing.equalTo(view).offset(-20)
            //make.width.equalTo(view)//.multipliedBy(0.2) 붙어버린다
            make.height.equalTo(searchTextField)
        }//아..레이블...아..ㅏ..
         /*
          [순위0][제목0][개봉일0]
          [순위1][제목1][개봉일^^]
          [순위2][제목2][개봉2]
          */
        
         rankLabels[0].snp.makeConstraints { make in
             make.leading.equalTo(view).offset(20)
             make.top.equalTo(searchButton.snp.bottom).offset(40)
             make.width.equalTo(50)
         }

         titleLabels[0].snp.makeConstraints { make in
             make.leading.equalTo(rankLabels[0].snp.trailing).offset(20)
             make.top.equalTo(rankLabels[0])
             make.width.equalTo(150)
         }

         dateLabels[0].snp.makeConstraints { make in
             make.leading.equalTo(titleLabels[0].snp.trailing).offset(20)
             make.top.equalTo(titleLabels[0])
             make.trailing.equalTo(view).offset(-20)
         }

         // 2위 레이블들의 제약조건
         rankLabels[1].snp.makeConstraints { make in
             make.leading.equalTo(view).offset(20)
             make.top.equalTo(rankLabels[0].snp.bottom).offset(40)
             make.width.equalTo(50)
         }

         titleLabels[1].snp.makeConstraints { make in
             make.leading.equalTo(rankLabels[1].snp.trailing).offset(20)
             make.top.equalTo(rankLabels[1])
             make.width.equalTo(150)
         }

         dateLabels[1].snp.makeConstraints { make in
             make.leading.equalTo(titleLabels[1].snp.trailing).offset(20)
             make.top.equalTo(titleLabels[1])
             make.trailing.equalTo(view).offset(-20)
         }

         // 3위 레이블들의 제약조건
         rankLabels[2].snp.makeConstraints { make in
             make.leading.equalTo(view).offset(20)
             make.top.equalTo(rankLabels[1].snp.bottom).offset(40)
             make.width.equalTo(50)
         }

         titleLabels[2].snp.makeConstraints { make in
             make.leading.equalTo(rankLabels[2].snp.trailing).offset(20)
             make.top.equalTo(rankLabels[2])
             make.width.equalTo(150)
         }

         dateLabels[2].snp.makeConstraints { make in
             make.leading.equalTo(titleLabels[2].snp.trailing).offset(20)
             make.top.equalTo(titleLabels[2])
             make.trailing.equalTo(view).offset(-20)
         }
    }
       
    private func rankMovies(for date: String) {
        let apiKey = "07918ad2a80648eb7bd0d5fb50437098"
        let urlString = "http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=\(apiKey)&targetDt=\(date)"
        
        //끝이아니라 그걸 감싸줘야 불러오죠,, 똥.떵.어.리
        AF.request(urlString).responseDecodable(of: BoxOfficeList.self) {  response in
            switch response.result {
                
            case .success(let result):
                let movies = result.boxOfficeResult.dailyBoxOfficeList // [Movie]
                
                self.rankLabels[0].text = movies[0].rank
                self.titleLabels[0].text = movies[0].movieNm
                self.dateLabels[0].text = movies[0].openDt
                
                self.rankLabels[1].text = movies[1].rank
                self.titleLabels[1].text = movies[1].movieNm
                self.dateLabels[1].text = movies[1].openDt
            
                self.rankLabels[2].text = movies[2].rank
                self.titleLabels[2].text = movies[2].movieNm
                self.dateLabels[2].text = movies[2].openDt
            case .failure(let error):
                print("왜 못가져왔냐믄 \(error)")
                
                
            }
        }
        
    }
    @objc func searchButtonTapped() {
        guard let date = searchTextField.text, date.count == 8 else {
            searchTextField.text = "올바른 형식으로 입력하세여"
            return
        }
        rankMovies(for: date)
    }
    
    
    func showYesterdayRank() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.locale = Locale(identifier: "ko_KR") // 안바뀌는데요?...
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        print(yesterday)
       
        let targetDt = dateFormatter.string(from: yesterday) // 15일인데 왜 어제가 13일이세여ㅛ? 영국기준이실게요
        rankMovies(for: targetDt)
    }
}










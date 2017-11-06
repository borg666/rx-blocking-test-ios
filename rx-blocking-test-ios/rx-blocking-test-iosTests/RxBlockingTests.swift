import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import rx_blocking_test_ios


class RxBlockingTests: XCTestCase {

    var isVisible: Variable<Bool> = Variable<Bool>(false)
    var onTapped: PublishSubject<Void> = PublishSubject<Void>()
    var disposeBag: DisposeBag = DisposeBag()

    func testBoolCollector() {
        let collector = BoolCollector().collect(from: &isVisible)
        isVisible.value = false
        isVisible.value = false
        isVisible.value = true
        XCTAssertEqual(collector.toArray, [true, true])
    }

    func testVoidCollector() {
        let collector = VoidCollector().collect(from: &onTapped)
        onTapped.onNext(())
        onTapped.onNext(())
        onTapped.onNext(())
        XCTAssertEqual(collector.toArray.count, 4)
    }
}

class VoidCollector {
    var disposeBag: DisposeBag = DisposeBag()
    var toArray: [Void] = [Void]()

    func collect( from variable: inout PublishSubject<Void>) -> Self {
        variable.asObservable()
            .subscribe(onNext: { () in
                self.toArray.append(())
            }).addDisposableTo(disposeBag)
        return self
    }
}

class BoolCollector {
     var disposeBag: DisposeBag = DisposeBag()
     var toArray: [Bool] = [Bool]()

     func collect( from variable: inout Variable<Bool>) -> Self {
        variable.asObservable()
            .subscribe(onNext: { (isVisible) in
                self.toArray.append(isVisible)
            }).addDisposableTo(disposeBag)
        return self
    }
}




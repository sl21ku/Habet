import Foundation
import Vision
import UIKit

enum AIImageVerificationService {

    /// Analyzes image data using Apple Vision to verify completion based on habit category.
    /// Returns a tuple (isSuccessful, descriptiveMessage).
    static func verifyImage(imageData: Data, category: String, completion: @escaping (Bool, String) -> Void) {
        guard let image = UIImage(data: imageData),
              let cgImage = image.cgImage else {
            completion(false, "画像の読み込みに失敗しました。有効な画像を選択してください。")
            return
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // Normalize category name for matching
        let isStudyOrWork = category.contains("勉強") || category.contains("読書") || category.contains("学習") || category.contains("作業") || category.contains("仕事")

        if isStudyOrWork {
            // Run text recognition (OCR)
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    completion(false, "文字の解析中にエラーが発生しました: \(error.localizedDescription)")
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion(false, "画像内に文字が見つかりませんでした。")
                    return
                }

                let detectedTexts = observations.compactMap { $0.topCandidates(1).first?.string }
                let totalCharacters = detectedTexts.reduce(0) { $0 + $1.count }

                if totalCharacters >= 5 {
                    let previewText = detectedTexts.prefix(3).joined(separator: ", ")
                    completion(true, "文字を検出しました！検出結果: [\(previewText)...]")
                } else {
                    completion(false, "写真の中に文字（本、ノート、PC画面等）が十分に検出されませんでした（検出: \(totalCharacters)文字）。テキストがはっきりと写るように再度撮影・選択してください。")
                }
            }

            request.recognitionLanguages = ["ja-JP", "en-US"]
            request.usesLanguageCorrection = true

            do {
                try handler.perform([request])
            } catch {
                completion(false, "画像解析の実行に失敗しました。")
            }

        } else {
            // Run image classification
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    completion(false, "オブジェクト分類中にエラーが発生しました: \(error.localizedDescription)")
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    completion(false, "画像の分類結果が得られませんでした。")
                    return
                }

                // Relevant keywords for workout/fitness/outdoor activities
                let fitnessKeywords = [
                    "dumbbell", "barbell", "weight", "exercise", "fitness", "sportswear",
                    "gymnasium", "shoe", "sneaker", "treadmill", "bicycle", "machine", "person", "human",
                    "arm", "leg", "body", "muscle", "court", "racket", "ball"
                ]

                let matched = observations
                    .filter { obs in
                        fitnessKeywords.contains { keyword in
                            obs.identifier.lowercased().contains(keyword)
                        }
                    }
                    .filter { $0.confidence > 0.05 }

                if !matched.isEmpty {
                    let topMatch = matched.first!
                    completion(true, "運動に関連する要素を検出しました！判定オブジェクト: \(topMatch.identifier) (信頼度 \(Int(topMatch.confidence * 100))%)")
                } else {
                    completion(false, "写真からトレーニング用品（ダンベル、スニーカー等）やフィットネス動作が検出されませんでした。別の写真を選ぶか、撮り直してください。")
                }
            }

            do {
                try handler.perform([request])
            } catch {
                completion(false, "画像解析の実行に失敗しました。")
            }
        }
    }
}

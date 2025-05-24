//
//  SessionContentView.swift
//  LetGo
//
//  Created by Gojaehyun on 5/23/25.
//

import SwiftUI
import Combine

struct SessionContentView: View {
    let sessions: [SessionInfo]
    @Binding var selectedSession: Int
    @Binding var showModeSetting: Bool
    
    @State private var isSessionActive = false

    var selectedSessionInfo: SessionInfo {
        sessions[selectedSession]
    }

    var sessionDuration: Int {
        // 0: 3분, 1: 5분, 2: 7분 (초 단위)
        switch selectedSession {
        case 0: return 180
        case 1: return 300
        case 2: return 420
        default: return 180
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            SessionCarouselSection(sessions: sessions, selectedSession: $selectedSession)
            SessionControlSection(
                session: selectedSessionInfo,
                showModeSetting: $showModeSetting,
                startSession: { isSessionActive = true }
            )
        }
        .padding(.top, 24)
        .fullScreenCover(isPresented: $isSessionActive) {
            SessionTimerView(duration: sessionDuration)
        }
    }
}

struct SessionCarouselSection: View {
    let sessions: [SessionInfo]
    @Binding var selectedSession: Int

    var body: some View {
        SessionCarouselView(sessions: sessions, selectedSession: $selectedSession)
    }
}

struct SessionControlSection: View {
    let session: SessionInfo
    @Binding var showModeSetting: Bool
    var startSession: () -> Void = {}

    var body: some View {
        VStack(spacing: 24) {
            Text(session.guide)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button(action: {
                startSession()
            }) {
                Text("시작하기")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 190, height: 190)
                    .background(Circle().fill(Color.orange.opacity(0.85)))
            }
            .padding(.top, 32)
            .padding(.bottom, 20)

            // Button(action: {
            //     showModeSetting = true
            // }) {
            //     Text("모드 설정")
            //         .font(.headline)
            //         .foregroundColor(.black)
            //         .padding(.horizontal, 32)
            //         .padding(.vertical, 12)
            //         .background(Capsule().fill(Color.white))
            //         .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
            // }
        }
    }
}

// SessionTimerView는 별도 파일로 이동합니다.

import SwiftUI
import MapKit
import CoreData

struct ClusterMapView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var isTabBarHidden: Bool
    @FetchRequest(
        entity: Writing.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Writing.date, ascending: false)],
        animation: .default
    ) var writings: FetchedResults<Writing>
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.5, longitude: 127.8), // 대한민국 중심
        span: MKCoordinateSpan(latitudeDelta: 3.5, longitudeDelta: 3.5)
    )
    @State private var selectedCluster: [Writing] = []
    @State private var showClusterOverlay = false
    @StateObject private var locationManager = LocationManager()
    @State private var selectedDetailWriting: Writing? = nil
    @State private var selectedEditingWriting: Writing? = nil
    @State private var useTransition: Bool = true
    @State private var showEditSheet = false
    @State private var showClusterSheet = false
    
    // Writing에 좌표가 있다고 가정 (latitude, longitude)
    var writingAnnotations: [WritingAnnotation] {
        writings.compactMap { w in
            guard let lat = w.value(forKey: "latitude") as? Double,
                  let lon = w.value(forKey: "longitude") as? Double else { return nil }
            return WritingAnnotation(writing: w, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
    }
    
    struct ClusterKey: Hashable {
        let lat: Double
        let lon: Double
    }
    
    var clusterRadius: Double {
        let delta = region.span.latitudeDelta
        if delta > 5 { return 5000 }      // 5km
        else if delta > 1 { return 2000 } // 2km
        else if delta > 0.2 { return 800 } // 800m
        else { return 300 }               // 300m
    }
    
    var clusterAnnotations: [WritingClusterAnnotation] {
        let annotations = writingAnnotations
        var clusters: [[WritingAnnotation]] = []
        var visited = Set<NSManagedObjectID>()
        for ann in annotations {
            if visited.contains(ann.id) { continue }
            var cluster = [ann]
            visited.insert(ann.id)
            for other in annotations {
                if ann.id == other.id || visited.contains(other.id) { continue }
                if ann.coordinate.distance(to: other.coordinate) < clusterRadius {
                    cluster.append(other)
                    visited.insert(other.id)
                }
            }
            clusters.append(cluster)
        }
        return clusters.map { group in
            WritingClusterAnnotation(
                coordinate: group.first!.coordinate,
                writings: group.map { $0.writing }
            )
        }
    }
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $region,
                showsUserLocation: false,
                annotationItems: clusterAnnotations
            ) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    Button(action: {
                        selectedCluster = annotation.writings
                        DispatchQueue.main.async {
                            showClusterSheet = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.theme)
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                            Text("\(annotation.writings.count)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            // 하단 그라디언트
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(1.0), Color.white.opacity(0.0)]),
                    startPoint: .bottom, endPoint: .top
                )
                .frame(height: 220)
                .ignoresSafeArea(edges: .bottom)
            }
            // 현재 위치 버튼
            Button(action: {
                if let loc = locationManager.lastLocation {
                    withAnimation {
                        region.center = loc.coordinate
                    }
                }
            }) {
                Image(systemName: "location.fill")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.85))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 18)
            .padding(.bottom, 110)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            // WritingDetailView 오버레이
            if let writing = selectedDetailWriting {
                let transition = useTransition ? AnyTransition.move(edge: .trailing) : .identity
                WritingDetailView(
                    writing: writing,
                    onClose: { withTransition in
                        if withTransition {
                            withAnimation(.easeInOut) { selectedDetailWriting = nil }
                        } else {
                            selectedDetailWriting = nil
                        }
                        useTransition = withTransition
                        isTabBarHidden = false
                    },
                    selectedEditingWriting: Binding(
                        get: { selectedEditingWriting },
                        set: { newValue in
                            selectedEditingWriting = newValue
                            if newValue != nil { showEditSheet = true }
                        }
                    )
                )
                .transition(transition)
                .zIndex(999)
            }
        }
        .sheet(isPresented: $showClusterSheet) {
            VStack(spacing: 0) {
                // 헤더
                HStack {
                    Text("\(selectedCluster.count)개의 기록")
                        .font(.headline)
                        .padding(.vertical, 16)
                }
                .padding(.horizontal)

                Divider()

                // 카드 리스트
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(selectedCluster, id: \.objectID) { writing in
                            WritingCard(
                                writing: writing,
                                onDelete: { w in
                                    context.delete(w)
                                    try? context.save()
                                },
                                onEdit: {
                                    selectedEditingWriting = writing
                                    showEditSheet = true
                                },
                                showEllipsis: false
                            )
                            .padding(.vertical, 20)
                            .onTapGesture {
                                showClusterSheet = false
                                withAnimation(.easeInOut) {
                                    selectedDetailWriting = writing
                                    isTabBarHidden = true
                                }
                                useTransition = true
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .id(selectedCluster.first?.objectID)
        .sheet(isPresented: $showEditSheet) {
            if let editingWriting = selectedEditingWriting {
                WritingEditView(writing: editingWriting, onSave: {
                    showEditSheet = false
                    selectedEditingWriting = nil
                    selectedDetailWriting = nil
                })
            } else {
                EmptyView()
            }
        }
    }
}

struct WritingAnnotation: Identifiable {
    var id: NSManagedObjectID { writing.objectID }
    let writing: Writing
    let coordinate: CLLocationCoordinate2D
}

struct WritingClusterAnnotation: Identifiable {
    var id: String { "\(coordinate.latitude),\(coordinate.longitude)" }
    let coordinate: CLLocationCoordinate2D
    let writings: [Writing]
}

extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return loc1.distance(from: loc2)
    }
}
 

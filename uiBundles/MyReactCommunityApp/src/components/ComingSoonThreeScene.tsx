import { useEffect, useRef } from 'react';
import * as THREE from 'three';

function createGear(
  radius: number,
  thickness: number,
  teethCount: number,
  color: number,
  emissive: number
): THREE.Group {
  const gear = new THREE.Group();

  const bodyMat = new THREE.MeshStandardMaterial({
    color,
    emissive,
    emissiveIntensity: 0.25,
    metalness: 0.55,
    roughness: 0.3,
  });

  const hubMat = new THREE.MeshStandardMaterial({
    color: 0xe2e8f0,
    metalness: 0.7,
    roughness: 0.25,
  });

  // Outer gear ring (torus-like cylinder body)
  const diskGeo = new THREE.CylinderGeometry(
    radius,
    radius,
    thickness,
    32
  );
  diskGeo.rotateX(Math.PI / 2);
  const disk = new THREE.Mesh(diskGeo, bodyMat);
  gear.add(disk);

  // Inner recessed hub
  const innerGeo = new THREE.CylinderGeometry(
    radius * 0.58,
    radius * 0.58,
    thickness * 1.12,
    24
  );
  innerGeo.rotateX(Math.PI / 2);
  const innerMat = new THREE.MeshStandardMaterial({
    color: 0x0b2340,
    metalness: 0.4,
    roughness: 0.5,
  });
  gear.add(new THREE.Mesh(innerGeo, innerMat));

  // Center axle collar
  const axleGeo = new THREE.CylinderGeometry(
    radius * 0.28,
    radius * 0.28,
    thickness * 1.3,
    20
  );
  axleGeo.rotateX(Math.PI / 2);
  gear.add(new THREE.Mesh(axleGeo, hubMat));

  // Gear teeth around circumference
  const toothWidth = (2 * Math.PI * radius) / (teethCount * 2.1);
  const toothHeight = radius * 0.26;
  const toothGeo = new THREE.BoxGeometry(
    toothWidth,
    toothHeight,
    thickness * 0.92
  );

  for (let i = 0; i < teethCount; i++) {
    const angle = (i / teethCount) * Math.PI * 2;
    const tooth = new THREE.Mesh(toothGeo, bodyMat);
    const dist = radius + toothHeight * 0.38;
    tooth.position.set(Math.cos(angle) * dist, Math.sin(angle) * dist, 0);
    tooth.rotation.z = angle - Math.PI / 2;
    gear.add(tooth);
  }

  return gear;
}

function createWrench(): THREE.Group {
  const wrench = new THREE.Group();
  const chromeMat = new THREE.MeshStandardMaterial({
    color: 0xdbeafe,
    metalness: 0.8,
    roughness: 0.2,
  });
  const gripMat = new THREE.MeshStandardMaterial({
    color: 0x0068b5,
    metalness: 0.3,
    roughness: 0.4,
  });

  // Handle shaft
  const shaftGeo = new THREE.BoxGeometry(0.28, 2.1, 0.16);
  wrench.add(new THREE.Mesh(shaftGeo, chromeMat));

  // Blue grip sleeve
  const gripGeo = new THREE.BoxGeometry(0.32, 1.1, 0.2);
  const grip = new THREE.Mesh(gripGeo, gripMat);
  grip.position.y = -0.35;
  wrench.add(grip);

  // Upper wrench head (U-shaped jaws)
  const headBaseGeo = new THREE.CylinderGeometry(0.42, 0.42, 0.2, 20);
  headBaseGeo.rotateX(Math.PI / 2);
  const headBase = new THREE.Mesh(headBaseGeo, chromeMat);
  headBase.position.set(0, 1.15, 0);
  wrench.add(headBase);

  const jawGeo = new THREE.BoxGeometry(0.16, 0.48, 0.22);
  const leftJaw = new THREE.Mesh(jawGeo, chromeMat);
  leftJaw.position.set(-0.22, 1.48, 0);
  leftJaw.rotation.z = -0.15;
  wrench.add(leftJaw);

  const rightJaw = new THREE.Mesh(jawGeo, chromeMat);
  rightJaw.position.set(0.22, 1.48, 0);
  rightJaw.rotation.z = 0.15;
  wrench.add(rightJaw);

  return wrench;
}

function createTrafficCone(): THREE.Group {
  const coneGroup = new THREE.Group();

  const orangeMat = new THREE.MeshStandardMaterial({
    color: 0xf97316,
    roughness: 0.35,
    metalness: 0.1,
  });
  const whiteMat = new THREE.MeshStandardMaterial({
    color: 0xffffff,
    emissive: 0xffffff,
    emissiveIntensity: 0.15,
    roughness: 0.25,
  });
  const baseMat = new THREE.MeshStandardMaterial({
    color: 0x1e293b,
    roughness: 0.6,
  });

  // Square base
  const baseGeo = new THREE.BoxGeometry(1.15, 0.14, 1.15);
  const base = new THREE.Mesh(baseGeo, baseMat);
  base.position.y = -0.75;
  coneGroup.add(base);

  // Main orange cone
  const coneGeo = new THREE.ConeGeometry(0.44, 1.45, 24);
  const cone = new THREE.Mesh(coneGeo, orangeMat);
  cone.position.y = 0;
  coneGroup.add(cone);

  // Reflective white stripes
  const stripe1Geo = new THREE.CylinderGeometry(0.22, 0.29, 0.22, 24);
  const stripe1 = new THREE.Mesh(stripe1Geo, whiteMat);
  stripe1.position.y = 0.12;
  coneGroup.add(stripe1);

  const stripe2Geo = new THREE.CylinderGeometry(0.32, 0.38, 0.2, 24);
  const stripe2 = new THREE.Mesh(stripe2Geo, whiteMat);
  stripe2.position.y = -0.25;
  coneGroup.add(stripe2);

  return coneGroup;
}

export function ComingSoonThreeScene() {
  const mountRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const container = mountRef.current;
    if (!container || typeof WebGLRenderingContext === 'undefined') return;

    let renderer: THREE.WebGLRenderer | null = null;
    try {
      renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    } catch {
      return;
    }

    const width = container.clientWidth || 480;
    const height = container.clientHeight || 300;
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    container.appendChild(renderer.domElement);

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(42, width / height, 0.1, 100);
    camera.position.set(0, 0.2, 8.2);

    const ambientLight = new THREE.AmbientLight(0xffffff, 1.4);
    scene.add(ambientLight);

    const mainLight = new THREE.DirectionalLight(0xffffff, 2.4);
    mainLight.position.set(5, 6, 7);
    scene.add(mainLight);

    const accentLight = new THREE.PointLight(0x00c7fd, 2.5, 20);
    accentLight.position.set(-5, -3, 5);
    scene.add(accentLight);

    const rootGroup = new THREE.Group();
    scene.add(rootGroup);

    // 1. Central Intel Blue Gear (12 teeth)
    const mainGear = createGear(1.25, 0.36, 12, 0x0068b5, 0x003c71);
    mainGear.position.set(-0.35, 0.15, 0);
    rootGroup.add(mainGear);

    // 2. Meshing Amber Maintenance Gear (8 teeth)
    const amberGear = createGear(0.85, 0.34, 8, 0xf59e0b, 0x78350f);
    amberGear.position.set(1.52, 1.22, -0.05);
    amberGear.rotation.z = Math.PI / 8;
    rootGroup.add(amberGear);

    // 3. Meshing Cyan Gear (9 teeth)
    const cyanGear = createGear(0.92, 0.32, 9, 0x00c7fd, 0x0369a1);
    cyanGear.position.set(-2.15, -1.15, -0.08);
    cyanGear.rotation.z = Math.PI / 9;
    rootGroup.add(cyanGear);

    // 4. 3D Maintenance Wrench
    const wrench = createWrench();
    wrench.position.set(-1.35, 0.85, 0.65);
    wrench.rotation.set(0.2, 0.25, -Math.PI / 4);
    rootGroup.add(wrench);

    // 5. 3D Construction Traffic Cone
    const cone = createTrafficCone();
    cone.position.set(1.55, -0.85, 0.55);
    cone.rotation.set(0.12, -0.35, -0.08);
    rootGroup.add(cone);

    const pointer = { x: 0, y: 0 };
    const handlePointerMove = (e: PointerEvent) => {
      const rect = container.getBoundingClientRect();
      if (!rect.width || !rect.height) return;
      pointer.x = ((e.clientX - rect.left) / rect.width - 0.5) * 2;
      pointer.y = -((e.clientY - rect.top) / rect.height - 0.5) * 2;
    };
    container.addEventListener('pointermove', handlePointerMove);

    const updateSize = () => {
      if (!renderer) return;
      const w = container.clientWidth || 480;
      const h = container.clientHeight || 300;
      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
    };
    const resizeObserver =
      typeof ResizeObserver !== 'undefined'
        ? new ResizeObserver(updateSize)
        : null;
    resizeObserver?.observe(container);
    window.addEventListener('resize', updateSize);

    let frameId = 0;
    const clock = new THREE.Clock();

    const animate = () => {
      frameId = window.requestAnimationFrame(animate);
      const t = clock.getElapsedTime();

      // Synchronized interlocking gear rotation
      const baseSpeed = 0.012;
      mainGear.rotation.z += baseSpeed;
      amberGear.rotation.z -= baseSpeed * (12 / 8);
      cyanGear.rotation.z -= baseSpeed * (12 / 9);

      // Gentle wrench tightening motion & cone float
      wrench.rotation.z = -Math.PI / 4 + Math.sin(t * 2.2) * 0.18;
      wrench.position.y = 0.85 + Math.sin(t * 1.6) * 0.08;
      cone.position.y = -0.85 + Math.cos(t * 1.8) * 0.06;

      rootGroup.rotation.y += (pointer.x * 0.4 - rootGroup.rotation.y) * 0.06;
      rootGroup.rotation.x += (-pointer.y * 0.25 - rootGroup.rotation.x) * 0.06;

      renderer?.render(scene, camera);
    };
    animate();

    return () => {
      window.cancelAnimationFrame(frameId);
      container.removeEventListener('pointermove', handlePointerMove);
      resizeObserver?.disconnect();
      window.removeEventListener('resize', updateSize);
      renderer?.dispose();
      if (renderer?.domElement && container.contains(renderer.domElement)) {
        container.removeChild(renderer.domElement);
      }
    };
  }, []);

  return (
    <div
      ref={mountRef}
      aria-label="3D maintenance animation"
      className="relative h-72 w-full max-w-2xl cursor-grab active:cursor-grabbing sm:h-80"
    />
  );
}

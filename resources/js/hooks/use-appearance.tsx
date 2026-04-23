import { AppearanceContext } from "@/context/AppearanceProvider";
import { useContext } from "react";

export const useAppearance = () => {
  const context = useContext(AppearanceContext);
  if (!context) {
    throw new Error('useAppearance must be used inside <AppearanceProvider>');
  }
  return context;
};
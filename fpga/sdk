#include <stdio.h>
#include <math.h>
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "xspi.h"

#define N 64
#define BRAM_BASE XPAR_BRAM_0_BASEADDR

XSpi SpiInstance;

// Twiddle factors
float W_real[N/2];
float W_imag[N/2];

// -----------------------------
// INIT TWIDDLES
// -----------------------------
void init_twiddles() {
    for (int i = 0; i < N/2; i++) {
        W_real[i] = cos(2 * M_PI * i / N);
        W_imag[i] = -sin(2 * M_PI * i / N);
    }
}

// -----------------------------
// SPI INIT (SLAVE MODE)
// -----------------------------
int init_spi() {
    XSpi_Config *Config;

    Config = XSpi_LookupConfig(XPAR_SPI_0_DEVICE_ID);
    if (Config == NULL) return XST_FAILURE;

    XSpi_CfgInitialize(&SpiInstance, Config, Config->BaseAddress);

    // SLAVE MODE
    XSpi_SetOptions(&SpiInstance, 0);

    XSpi_Start(&SpiInstance);
    XSpi_IntrGlobalDisable(&SpiInstance);

    return XST_SUCCESS;
}

// -----------------------------
// FFT FUNCTION
// -----------------------------
void fft(float real[], float imag[]) {

    int i, j, k, m;
    int step;

    // Bit reversal
    j = 0;
    for (i = 0; i < N; i++) {
        if (i < j) {
            float temp;
            temp = real[i]; real[i] = real[j]; real[j] = temp;
            temp = imag[i]; imag[i] = imag[j]; imag[j] = temp;
        }
        m = N >> 1;
        while (j >= m && m >= 2) {
            j -= m;
            m >>= 1;
        }
        j += m;
    }

    // FFT stages
    for (step = 1; step < N; step <<= 1) {
        int jump = step << 1;

        for (i = 0; i < step; i++) {

            float wr = W_real[(i * (N/2)) / step];
            float wi = W_imag[(i * (N/2)) / step];

            for (j = i; j < N; j += jump) {
                k = j + step;

                float tr = wr * real[k] - wi * imag[k];
                float ti = wr * imag[k] + wi * real[k];

                real[k] = real[j] - tr;
                imag[k] = imag[j] - ti;

                real[j] = real[j] + tr;
                imag[j] = imag[j] + ti;
            }
        }
    }
}

// -----------------------------
// MAIN
// -----------------------------
int main() {

    float real[N], imag[N];
    int samples[N];
    float mag[N];

    u8 spi_tx[N];
    u8 spi_rx[N];

    xil_printf("===== FFT + SPI SLAVE =====\n\r");

    // Init
    if (init_spi() != XST_SUCCESS) {
        xil_printf("SPI INIT FAILED\n\r");
        return -1;
    }

    init_twiddles();

    // -----------------------------
    // Read BRAM (pre-recorded "hi")
    // -----------------------------
    for (int i = 0; i < N; i++) {
        samples[i] = Xil_In32(BRAM_BASE + i*4);
        real[i] = (float)samples[i];
        imag[i] = 0;

        xil_printf("Sample[%d] = %d\n\r", i, samples[i]);
    }

    // -----------------------------
    // FFT
    // -----------------------------
    fft(real, imag);

    xil_printf("\nFFT DONE\n\r");

    // -----------------------------
    // Compute magnitude (SAFE)
    // -----------------------------
    float max_val = 0.0;

    for (int i = 0; i < N; i++) {
        mag[i] = fabs(real[i]) + fabs(imag[i]);   // safe magnitude

        if (mag[i] > max_val)
            max_val = mag[i];
    }

    // -----------------------------
    // Scale to 8-bit (FIXED)
    // -----------------------------
    for (int i = 0; i < N; i++) {

        float scaled = (mag[i] * 255.0) / (max_val + 1e-6);

        if (scaled > 255) scaled = 255;
        if (scaled < 0)   scaled = 0;

        spi_tx[i] = (u8)scaled;

        xil_printf("TX[%d] = %d\n\r", i, spi_tx[i]);
    }

    // Remove DC component (optional but good)
    spi_tx[0] = 0;

    xil_printf("\nWaiting for Raspberry Pi...\n\r");

    // -----------------------------
    // SPI SLAVE LOOP
    // -----------------------------
    while (1) {

        XSpi_Transfer(&SpiInstance, spi_tx, spi_rx, N);

        xil_printf("SPI transfer done!\n\r");

        // Debug RX (from Pi)
        for (int i = 0; i < 8; i++) {
            xil_printf("RX[%d]=%d ", i, spi_rx[i]);
        }
        xil_printf("\n\r");
    }

    return 0;
}
